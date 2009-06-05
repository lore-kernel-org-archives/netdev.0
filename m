From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio_net: Set correct gso->hdr_len
Date: Fri, 5 Jun 2009 13:51:05 +0930
Message-ID: <200906051351.06385.rusty@rustcorp.com.au>
References: <20090604105917.GA28273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40518 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbZFEEVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 00:21:11 -0400
In-Reply-To: <20090604105917.GA28273@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Jun 2009 08:29:18 pm Herbert Xu wrote:
> Hi:
>
> virtio_net: Set correct gso->hdr_len
>
> Through a bug in the tun driver, I noticed that virtio_net is
> producing bogus hdr_len values.  In particular, it only includes
> the IP header in the linear area, and excludes the entire TCP
> header.  This causes the TCP header to be copied twice for each
> packet.  (The bug omitted the second copy :)
>
> This patch corrects this.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4d1d479..1c9cedd 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -470,7 +470,7 @@ static int xmit_skb(struct virtnet_info *vi, struct
> sk_buff *skb) }
>
>  	if (skb_is_gso(skb)) {
> -		hdr->hdr_len = skb_transport_header(skb) - skb->data;
> +		hdr->hdr_len = skb_headlen(skb);

Ouch!

But are we allowed to make the assumption that skb_headlen() == 
skb_transport_header(skb) + sizeof(transport header) ?  Or should we be 
checking that here?

Also how did this ever work?  Why are we getting packets through at all?

Damn, I'm away from my test boxes an I really want to benchmark this fix.
Rusty.
