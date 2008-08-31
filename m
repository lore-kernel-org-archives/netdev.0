From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [2.6 patch] wan/hdlc_x25.c: fix a NULL dereference
Date: Sun, 31 Aug 2008 19:08:35 +0200
Message-ID: <m3bpz9glik.fsf@maximus.localdomain>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:40758 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648AbYHaRIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 13:08:39 -0400
In-Reply-To: <20080827220549.GS11734@cs181140183.pp.htv.fi> (Adrian Bunk's message of "Thu\, 28 Aug 2008 01\:05\:49 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk <bunk@kernel.org> writes:

> --- a/drivers/net/wan/hdlc_x25.c
> +++ b/drivers/net/wan/hdlc_x25.c
> @@ -163,10 +163,8 @@ static void x25_close(struct net_device *dev)
>  
>  static int x25_rx(struct sk_buff *skb)
>  {
> -	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
> -		skb->dev->stats.rx_dropped++;
> +	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
>  		return NET_RX_DROP;
> -	}
>  

Right, thanks... though I will update the stats anyway.
-- 
Krzysztof Halasa
