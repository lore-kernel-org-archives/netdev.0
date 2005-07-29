From: Diego Beltrami <diego.beltrami@HIIT.FI>
Subject: Re: [hipl-users] Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for
	Linux
Date: Fri, 29 Jul 2005 18:33:36 +0300
Message-ID: <1122651216.25842.67.camel@odysse>
References: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au>
Reply-To: diego.beltrami@HIIT.FI
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: infrahip@HIIT.FI, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Diego Beltrami <diego.beltrami@hiit.fi> wrote:
> > 
> > we have been working for three months to implement a new IPsec mode,
> > the "BEET" mode, for Linux. Below is a link to the BEET specification
> > and
> > the abstract:
> > 
> > http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt
> 
> Thanks for the patch guys, this is really interesting.

Thanks Herbert for your feedback!


> > extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
> > diff -urN linux-2.6.12.2/net/ipv4/esp4.c
> > linux-beet-2.6.12.2/net/ipv4/esp4.c
> > --- linux-2.6.12.2/net/ipv4/esp4.c      2005-06-30 02:00:53.000000000 +0300
> > +++ linux-beet-2.6.12.2/net/ipv4/esp4.c 2005-07-25 14:39:11.000000000
> 
> Although the document only talks about ESP, as far as I can see
> the encapsulation can be applied to AH/IPComp just as well.
> So how about moving this stuff to the generic xfrm_input/xfrm_output
> functions?

The BEET code is already present in xfrm_input/xfrm_output functions and
it applies ESP encapsulation merely because of SA and SP set by means
setkey. As a consequence, if SA and SP are correctly set for AH the flow
goes through the AH functions. 

The modifications in the ESP functions are due to the hybrid cases when
Inner and Outer address families are different; in those cases the
values returned by espX functions are not coherent.

I tried to change SA and SP so that AH is used and the flow correctly
goes through AH functions but the problem has been revealed to be
something else. In particular, it seems that the AH functions deal with
the pointers contained in skb (skb->data, skb->nh, skb->h etc) in a
slightly different way than ESP functions. (Can anyone say more?)

Surely BEET will work also for AH with minor changes, even though we
only tried the ESP encapsulation.
This will require some time to inspect and analyze the exact situation.

In any case, as a result, I would say the code is already generic
itself.


On the other hand I don't know about IPComp, so I wouldn't say anything.
Hence if You could please give some hints, they will be more than
appreciated.

> 
> Also, if you're going to do cross-family transforms, it should be
> done for both BEET and plain tunnel-mode.

Potentially it could be possible also for plain tunnel-mode: this will
require further analysis.

For further discussion and advice, please give feedback.
Thank You very much!

Cheers,

--Diego
