From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/7] 8139cp: Fix TSO/scatter-gather descriptor setup
Date: Mon, 21 Sep 2015 23:01:39 +0200
Message-ID: <20150921210139.GB4559@electric-eye.fr.zoreil.com>
References: <1442843991.7367.4.camel@infradead.org>
 <1442844165.7367.14.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40368 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695AbbIUVCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:02:30 -0400
Content-Disposition: inline
In-Reply-To: <1442844165.7367.14.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 058f835..07621b5 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
[...]
> @@ -865,20 +864,20 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
>  		txd->addr = cpu_to_le64(first_mapping);
>  		wmb();
>  
> -		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		ctrl = first_eor | first_len | FirstFrag | DescOwn;
> +		if (mss)
> +			ctrl |= LargeSend |
> +				((mss & MSSMask) << MSSShift);

			ctrl |= LargeSend | ((mss & MSSMask) << MSSShift);

> +		else if (skb->ip_summed == CHECKSUM_PARTIAL) {
>  			if (ip->protocol == IPPROTO_TCP)
> -				txd->opts1 = cpu_to_le32(first_eor | first_len |
> -							 FirstFrag | DescOwn |
> -							 IPCS | TCPCS);
> +				ctrl |= IPCS | TCPCS;
>  			else if (ip->protocol == IPPROTO_UDP)
> -				txd->opts1 = cpu_to_le32(first_eor | first_len |
> -							 FirstFrag | DescOwn |
> -							 IPCS | UDPCS);
> +				ctrl |= IPCS | UDPCS;
>  			else
>  				BUG();

Can you pile a patch to replace BUG with WARN_ON_ONCE(1) ?

-- 
Ueimor
