From: Jeff Garzik <jeff@garzik.org>
Subject: Re: wan/hdlc_x25.c: fix a NULL dereference
Date: Sat, 13 Sep 2008 15:56:07 -0400
Message-ID: <48CC1AD7.6000909@garzik.org>
References: <20080827220549.GS11734@cs181140183.pp.htv.fi>	<m3bpz9glik.fsf@maximus.localdomain> <48BE9B52.8050003@garzik.org>	<m3bpz5kxzj.fsf@maximus.localdomain> <m37i9tkxnf.fsf_-_@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52824 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbYIMT4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:56:13 -0400
In-Reply-To: <m37i9tkxnf.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> WAN: fixes a NULL dereference in hdlc_x25.
> 
> Reported-by: Adrian Bunk <bunk@kernel.org>.
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
> diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
> index 8b7e5d2..cbcbf6f 100644
> --- a/drivers/net/wan/hdlc_x25.c
> +++ b/drivers/net/wan/hdlc_x25.c
> @@ -163,15 +163,17 @@ static void x25_close(struct net_device *dev)
>  
>  static int x25_rx(struct sk_buff *skb)
>  {
> +	struct net_device *dev = skb->dev;
> +
>  	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
> -		skb->dev->stats.rx_dropped++;
> +		dev->stats.rx_dropped++;
>  		return NET_RX_DROP;
>  	}
>  
> -	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
> +	if (lapb_data_received(dev, skb) == LAPB_OK)
>  		return NET_RX_SUCCESS;
>  
> -	skb->dev->stats.rx_errors++;
> +	dev->stats.rx_errors++;
>  	dev_kfree_skb_any(skb);
>  	return NET_RX_DROP;

applied


