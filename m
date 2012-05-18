From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH v4 6/6] net: sh_eth: use NAPI
Date: Fri, 18 May 2012 10:44:43 +0900
Message-ID: <4FB5A98B.501@renesas.com>
References: <4FB32D17.30404@renesas.com>
 <20120517103308.GA15830@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <20120517103308.GA15830@electric-eye.fr.zoreil.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/05/17 19:33, Francois Romieu wrote:
> Shimoda, Yoshihiro <yoshihiro.shimoda.uh@renesas.com> :
> [...]
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index c64a31c..edc7dfe 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
< snip >
>> @@ -1678,19 +1710,15 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>>  	struct sh_eth_private *mdp = netdev_priv(ndev);
>>  	struct sh_eth_txdesc *txdesc;
>>  	u32 entry;
>> -	unsigned long flags;
>>
>> -	spin_lock_irqsave(&mdp->lock, flags);
>>  	if ((mdp->cur_tx - mdp->dirty_tx) >= (mdp->num_tx_ring - 4)) {
>>  		if (!sh_eth_txfree(ndev)) {
> 
> There are now two racing sh_eth_txfree and there is no [PATCH v4 7/6].
> 
> If I may suggest a slightly different approach, I would apply the patch
> below before anything NAPI related:

Thank you very much for the suggestion. I will modify the NAPI patch to fix
the racing using your suggestion.
(Because the original driver (before NAPI) was already locked by mdp->lock
 in sh_eth_interrupt(), I think that the original driver doesn't have the
 racing issue.)

Best regards,
Yoshihiro Shimoda
