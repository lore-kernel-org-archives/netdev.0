From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH] mwifiex: use is_zero_ether_addr() instead of memcmp()
Date: Fri, 24 Aug 2012 10:56:45 +0800
Message-ID: <CAPgLHd--KY+zNjUwOHKgEJuTfJuoA=7vKR3JMBUgUc+BtjC9Ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linville@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: bzhao@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:50732 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab2HXC4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 22:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zhao,

On 08/24/2012 02:28 AM, Bing Zhao wrote:
> Hi Wei,
>
> Thanks for the patch.
>
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> Using is_zero_ether_addr() instead of directly use
>> memcmp() to determine if the ethernet address is all
>> zeros.
>>
>> spatch with a semantic match is used to found this problem.
>> (http://coccinelle.lip6.fr/)
> Apparently there are two more occurrences of zero_mac (scan.c:843)

This is part is special:

memcmp(scan_cfg_out->specific_bssid, &zero_mac, sizeof(zero_mac)))

&zero_mac equal zero_mac, but it missing to spatch.


>  and bc_mac (sta_cmd.c:596).
> But I can fix them when I get the chance.

This part will be sent in other patch which using
is_broadcast_ether_addr()

>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> Acked-by: Bing Zhao <bzhao@marvell.com>
>
> Thanks,
> Bing
>
>> ---
>>  drivers/net/wireless/mwifiex/sta_cmdresp.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
>> index 0b09004..a2a33dc 100644
>> --- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
>> +++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
>> @@ -17,6 +17,8 @@
>>   * this warranty disclaimer.
>>   */
>>
>> +#include <linux/etherdevice.h>
>> +
>>  #include "decl.h"
>>  #include "ioctl.h"
>>  #include "util.h"
>> @@ -736,7 +738,6 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
>>  {
>>  	struct host_cmd_ds_802_11_ibss_status *ibss_coal_resp =
>>  					&(resp->params.ibss_coalescing);
>> -	u8 zero_mac[ETH_ALEN] = { 0, 0, 0, 0, 0, 0 };
>>
>>  	if (le16_to_cpu(ibss_coal_resp->action) == HostCmd_ACT_GEN_SET)
>>  		return 0;
>> @@ -745,7 +746,7 @@ static int mwifiex_ret_ibss_coalescing_status(struct mwifiex_private *priv,
>>  		"info: new BSSID %pM\n", ibss_coal_resp->bssid);
>>
>>  	/* If rsp has NULL BSSID, Just return..... No Action */
>> -	if (!memcmp(ibss_coal_resp->bssid, zero_mac, ETH_ALEN)) {
>> +	if (is_zero_ether_addr(ibss_coal_resp->bssid)) {
>>  		dev_warn(priv->adapter->dev, "new BSSID is NULL\n");
>>  		return 0;
>>  	}
>>
>
>
