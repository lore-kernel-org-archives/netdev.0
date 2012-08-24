From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] mwifiex: use is_broadcast_ether_addr() instead of
 memcmp()
Date: Thu, 23 Aug 2012 20:28:43 -0700
Message-ID: <477F20668A386D41ADCC57781B1F7043083B0BBB70@SC-VEXCH1.marvell.com>
References: <CAPgLHd9YDVVJ+RMZTR4ubQy_cvMPYgWgFWpjpdUuAeu5B6T1Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:56982 "EHLO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757725Ab2HXD3U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 23:29:20 -0400
In-Reply-To: <CAPgLHd9YDVVJ+RMZTR4ubQy_cvMPYgWgFWpjpdUuAeu5B6T1Bw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei,

Thanks for the patch again.

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using is_broadcast_ether_addr() instead of directly use
> memcmp() to determine if the ethernet address is broadcast
> address.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/wireless/mwifiex/sta_cmd.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
> index df3a33c..45461ca 100644
> --- a/drivers/net/wireless/mwifiex/sta_cmd.c
> +++ b/drivers/net/wireless/mwifiex/sta_cmd.c
> @@ -17,6 +17,8 @@
>   * this warranty disclaimer.
>   */
> 
> +#include <linux/etherdevice.h>

This is not needed. One of local .h file has included it already.

This reminds me that your previous patch (is_zero_ether_addr) also had this inclusion.
Could you please resend v2 for both patches?

Thanks,
Bing

> +
>  #include "decl.h"
>  #include "ioctl.h"
>  #include "util.h"
> @@ -551,7 +553,6 @@ mwifiex_cmd_802_11_key_material(struct mwifiex_private *priv,
>  	struct host_cmd_tlv_mac_addr *tlv_mac;
>  	u16 key_param_len = 0, cmd_size;
>  	int ret = 0;
> -	const u8 bc_mac[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
> 
>  	cmd->command = cpu_to_le16(HostCmd_CMD_802_11_KEY_MATERIAL);
>  	key_material->action = cpu_to_le16(cmd_action);
> @@ -593,7 +594,7 @@ mwifiex_cmd_802_11_key_material(struct mwifiex_private *priv,
>  			/* set 0 when re-key */
>  			key_material->key_param_set.key[1] = 0;
> 
> -		if (0 != memcmp(enc_key->mac_addr, bc_mac, sizeof(bc_mac))) {
> +		if (!is_broadcast_ether_addr(enc_key->mac_addr)) {
>  			/* WAPI pairwise key: unicast */
>  			key_material->key_param_set.key_info |=
>  				cpu_to_le16(KEY_UNICAST);
