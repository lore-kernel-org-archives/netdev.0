From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH] [XFRM] Beet: Fix output for ipv6
Date: Mon, 25 Feb 2008 22:31:00 +0200
Message-ID: <200802252231.01021.joakim.koskela@hiit.fi>
References: <200802081812.18985.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:48623 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755672AbYBYUbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 15:31:06 -0500
In-Reply-To: <200802081812.18985.joakim.koskela@hiit.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert, 

Have you had a chance to look this, or are you working on something else for 
it?

On Friday 08 February 2008 18:12, Joakim Koskela wrote:
> Hi,
>
> This patch fixes the ipv6 mode of ipsec beet. It has been using logic
> similar to tunnel mode, making it crash during esp packaging.
>
> Signed-off-by: Joakim Koskela <jookos@gmail.com>
> ---
>  net/ipv6/xfrm6_mode_beet.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
> index 0527d11..0395800 100644
> --- a/net/ipv6/xfrm6_mode_beet.c
> +++ b/net/ipv6/xfrm6_mode_beet.c
> @@ -40,11 +40,14 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
>  static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
>  {
>  	struct ipv6hdr *top_iph;
> +	u8 *prevhdr;
> +	int hdr_len;
>
> +	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
> +	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
>  	skb_set_network_header(skb, -x->props.header_len);
> -	skb->mac_header = skb->network_header +
> -			  offsetof(struct ipv6hdr, nexthdr);
> -	skb->transport_header = skb->network_header + sizeof(*top_iph);
> +	skb->transport_header = skb->network_header + hdr_len;
> +	__skb_pull(skb, hdr_len);
>
>  	xfrm6_beet_make_header(skb);
>

