From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix rx-usecs interrupt pacing
 consistency
Date: Fri, 3 Jun 2016 19:47:05 +0300
Message-ID: <5751B489.9070809@ti.com>
References: <1464873292-17011-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <575034D8.4040500@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:46267 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbcFCQrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 12:47:09 -0400
In-Reply-To: <575034D8.4040500@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2016 04:30 PM, Ivan Khoronzhuk wrote:
> On 02.06.16 16:14, Ivan Khoronzhuk wrote:
>> The rx-usecs shouldn't be changed while interface down/up.
>> Currently, for instance, if it's set to 100us, after interface
>> down/up it's 500us. It's a hidden bug that can lead to lavish
>> interrupt pacing time increasing while "down/up" up to max value.
>>
>> Steps to reproduce:
>> - set rx-usecs to be 100us
>> - down/up interface
>> - read new unexpected rx-usecs
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>
>> Based on ti-linux-4.4.y
> Please ignore this line, it's added by mistake.
> The patch is based on master.
>

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

>
>>
>>   drivers/net/ethernet/ti/cpsw.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 7b44587..9919cb3 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -1352,7 +1352,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>       if (priv->coal_intvl != 0) {
>>           struct ethtool_coalesce coal;
>>
>> -        coal.rx_coalesce_usecs = (priv->coal_intvl << 4);
>> +        coal.rx_coalesce_usecs = priv->coal_intvl;
>>           cpsw_set_coalesce(ndev, &coal);
>>       }
>>
>>
>


-- 
regards,
-grygorii
