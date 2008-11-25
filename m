From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 16:42:03 +0000
Message-ID: <1227631323.3109.7.camel@achroite>
References: <20081125083250.2ad7d75d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:39256 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbYKYQmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 11:42:09 -0500
In-Reply-To: <20081125083250.2ad7d75d@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-25 at 08:32 -0800, Arjan van de Ven wrote:
> From 97a8ab520c378568e172c555a156b469137a3828 Mon Sep 17 00:00:00 200=
1
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Tue, 25 Nov 2008 08:30:04 -0800
> Subject: [PATCH] net: make skb_truesize_bug() call WARN()
>=20
> The truesize message check is important enough to make it print "BUG"=
 to the
> user console... lets also make it important enough to spit a backtrac=
e/module list
> etc so that kerneloops.org can track them.
>=20
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
>  net/core/skbuff.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 391be91..1a1f4d1 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -149,7 +149,7 @@ void skb_under_panic(struct sk_buff *skb, int sz,=
 void *here)
> =20
>  void skb_truesize_bug(struct sk_buff *skb)
>  {
> -	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
> +	WARN(1, KERN_ERR "SKB BUG: Invalid truesize (%u) "
>  	       "len=3D%u, sizeof(sk_buff)=3D%Zd\n",
>  	       skb->truesize, skb->len, sizeof(struct sk_buff));
>  }

=EF=BB=BFThe bug reports I've seen (with my Debian hat on, not relating=
 to sfc)
show that configurations that trigger this warning are likely to trigge=
r
many times over and there's nothing the user can do about it.  So by al=
l
means do make the warning more obvious, but please make it WARN_ON_ONCE
and then use printk qualified by net_ratelimit().

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

