From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: mcast snooping, fix IPv6 MLD checksum
	calculation
Date: Sun, 27 Mar 2011 15:52:42 +0800
Message-ID: <20110327075242.GA24677@gondor.apana.org.au>
References: <20110327034404.GC31916@Sellars> <1301207244-10428-1-git-send-email-linus.luessing@web.de> <1301207244-10428-2-git-send-email-linus.luessing@web.de> <20110327063749.GA24299@gondor.apana.org.au> <20110327070645.GA1734@Sellars>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47502 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab1C0Hwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 03:52:54 -0400
Content-Disposition: inline
In-Reply-To: <20110327070645.GA1734@Sellars>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 27, 2011 at 09:06:45AM +0200, Linus L=FCssing wrote:
> So instead of 'if (!csum_fold(skb2->csum))' it should be this?
> ---
> if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
>                      skb2->len, nexthdr, skb2->csum))
> ---
> (I'm peeking a little bit at
> http://lxr.linux.no/linux+*/net/ipv6/netfilter.c#L98)

Yes that looks about right.

> Hmm, if so, then I don't know how to test and verify that now though.

You'd need a NIC that supported this to test.  Although I wouldn't
worry about it too much as the same code patterns appears over and
over again in our stack.  Perhaps we should put it in a helper.

Thanks,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
