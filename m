From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-next 04/17] ndisc: Introduce ndisc_fill_redirect_hdr_option().
Date: Wed, 19 Dec 2012 12:08:09 +0900
Message-ID: <50D12F99.30606@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org> <50D04B4B.7060002@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:57651 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754071Ab2LSDIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 22:08:10 -0500
In-Reply-To: <50D04B4B.7060002@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  net/ipv6/ndisc.c |   21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index a181113..0a4f3a9 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1332,6 +1332,19 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
>  	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
>  }
>  
> +static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *orig_skb,
> +					  int rd_len)
> +{
> +	memset(opt, 0, 8);
> +	*(opt++) = ND_OPT_REDIRECT_HDR;
> +	*(opt++) = (rd_len >> 3);
> +	opt += 6;
> +
> +	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
> +
> +	return opt;
> +}
> +
>  void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  {
>  	struct net_device *dev = skb->dev;

By the way, is it really safe to use memcpy here?
Should we use skb_copy_bits() instead?

--yoshfuji
