From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/4] pch_gbe: vlan skb len fix
Date: Mon, 9 Jul 2012 21:33:23 +0100
Message-ID: <1341866003.2535.60.camel@bwh-desktop.uk.solarflarecom.com>
References: <40680C535D6FE6498883F1640FACD44D010BFC0E@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63651 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753182Ab2GIUd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 16:33:27 -0400
In-Reply-To: <40680C535D6FE6498883F1640FACD44D010BFC0E@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-09 at 06:30 -0700, Andy Cress wrote:
> Author: Veaceslav Falico <vfalico@redhat.com>
> Date:   Tue Apr 10 08:14:17 2012 +0200
> 
>     pch_gbe: correctly verify skb->len in vlan case
>              to avoid bogus transfer length errors.

This check shouldn't be necessary at all.  Maybe you should remove it
instead of correcting the check?

Also, these patches are word-wrapped, and would not be applicable in
this form.  See Documentation/email-clients.txt.

Ben.

> Signed-off-by: Andy Cress <andy.cress@us.kontron.com>
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 30ef285..04b0e49 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -2158,8 +2158,10 @@ static int pch_gbe_xmit_frame(struct sk_buff
> *skb, struct net_device *netdev)
>  	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>  	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
>  	unsigned long flags;
> +	int offset;
>  
> -	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
> +	offset = skb->protocol == htons(ETH_P_8021Q) ? 0 : 4;
> +	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size -
> offset))) {
>  		pr_err("Transfer length Error: skb len: %d > max: %d\n",
>  		       skb->len, adapter->hw.mac.max_frame_size);
>  		dev_kfree_skb_any(skb);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
