From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 1/7] stmmac: review napi gro support
Date: Thu, 04 Apr 2013 08:20:03 +0200
Message-ID: <515D1B93.2080607@st.com>
References: <1364967689-11155-1-git-send-email-peppe.cavallaro@st.com> <1365004913.2897.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:59949 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763354Ab3DDGUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 02:20:08 -0400
In-Reply-To: <1365004913.2897.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2013 6:01 PM, Ben Hutchings wrote:
> On Wed, 2013-04-03 at 07:41 +0200, Giuseppe CAVALLARO wrote:
>> This patch is to:
>> o use napi_gro_flush() before calling __napi_complete()
>
> napi_complete() already does that, and some other important things.  Why
> do you think it makes sense to call __napi_complete() directly?

yes Ben you are right. In fact Eric already alerted me on this.
It is my fault, I'll remove this in my next set.

>
> Ben.
>
>> o turn on NETIF_F_GRO by default
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++--
>>   1 files changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 6b26d31..8b69e3b 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2046,7 +2046,8 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
>>
>>   	work_done = stmmac_rx(priv, budget);
>>   	if (work_done < budget) {
>> -		napi_complete(napi);
>> +		napi_gro_flush(napi, false);
>> +		__napi_complete(napi);
>>   		stmmac_enable_dma_irq(priv);
>>   	}
>>   	return work_done;
>> @@ -2586,7 +2587,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>
>>   	ndev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>>   			    NETIF_F_RXCSUM;
>> -	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
>> +	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA | NETIF_F_GRO;
>>   	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
>>   #ifdef STMMAC_VLAN_TAG_USED
>>   	/* Both mac100 and gmac support receive VLAN tag detection */
>
