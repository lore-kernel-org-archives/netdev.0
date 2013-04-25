From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Thu, 25 Apr 2013 16:46:17 +0800
Message-ID: <20130425084617.GA27463@gondor.apana.org.au>
References: <1366367073.3205.105.camel@edumazet-glaptop>
 <20130419.142852.1914290650706288260.davem@davemloft.net>
 <20130422013557.GF15680@verge.net.au>
 <20130421.214433.1585372696150221161.davem@davemloft.net>
 <20130422021341.GG15680@verge.net.au>
 <20130423075042.GA25776@verge.net.au>
 <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, xeb@mail.ru
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:32920 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751089Ab3DYIqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:46:32 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 01:47:34PM -0700, Jesse Gross wrote:
> On Tue, Apr 23, 2013 at 12:50 AM, Simon Horman <horms@verge.net.au> wrote:
> > [ CC Herbert ]
> >
> > On Mon, Apr 22, 2013 at 11:13:41AM +0900, Simon Horman wrote:
> >> On Sun, Apr 21, 2013 at 09:44:33PM -0400, David Miller wrote:
> >> > From: Simon Horman <horms@verge.net.au>
> >> > Date: Mon, 22 Apr 2013 10:35:57 +0900
> >> >
> >> > > On Fri, Apr 19, 2013 at 02:28:52PM -0400, David Miller wrote:
> >> > >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> > >> Date: Fri, 19 Apr 2013 03:24:33 -0700
> >> > >>
> >> > >> > On Fri, 2013-04-19 at 15:48 +0900, Simon Horman wrote:
> >> > >> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >> > >> >> ---
> >> > >> >>  net/ipv4/gre.c |    2 +-
> >> > >> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> > >> >>
> >> > >> >> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> >> > >> >> index d2d5a99..0ae998b 100644
> >> > >> >> --- a/net/ipv4/gre.c
> >> > >> >> +++ b/net/ipv4/gre.c
> >> > >> >> @@ -168,7 +168,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
> >> > >> >>       /* segment inner packet. */
> >> > >> >>       enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> >> > >> >>       segs = skb_mac_gso_segment(skb, enc_features);
> >> > >> >> -     if (!segs || IS_ERR(segs))
> >> > >> >> +     if (IS_ERR_OR_NULL(segs))
> >> > >> >>               goto out;
> >> > >> >>
> >> > >> >>       skb = segs;
>
> I don't think this is actually a problem since there is a check for
> skb_is_gso() earlier in the code path and no GSO types are supported
> in the call to __skb_gso_segment(). However, I can't say that I'm a
> big fan of this function possibly returning NULL since it makes it
> unnecessarily difficult to reason about.

Please refer to the description in the original changelog
(576a30eb6453439b3c37ba24455ac7090c247b5a).  The purpose of
the NULL return value is to indicate that we're processing a
packet that will be segmented by the hardware, i.e., the only
reason we're running the software GSO code on this packet is
to verify its integrity because it came from an untrusted source.

We can certainly get rid of the NULL return value and directly test
for the verification only case but I'm not sure if it's really worth
it.

Perhaps add an wrapper for the IS_ERR_OR_NULL with a descriptive
name?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
