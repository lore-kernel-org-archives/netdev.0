From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Mon, 6 Aug 2007 09:49:58 +0300
Message-ID: <200708060949.58758.joakim.koskela@hiit.fi>
References: <200707161506.47915.joakim.koskela@hiit.fi> <469BBD4C.5040503@trash.net> <200707171730.21655.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:46868 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbXHFGu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 02:50:29 -0400
In-Reply-To: <200707171730.21655.joakim.koskela@hiit.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 July 2007 17:30:21 Joakim Koskela wrote:
> > Joakim Koskela wrote:
> > > diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
> > > index fa1902d..7a39f4c 100644
> > > --- a/net/ipv4/xfrm4_input.c
> > > +++ b/net/ipv4/xfrm4_input.c
> > > @@ -108,7 +108,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16
> > > encap_type) if (x->mode->input(x, skb))
> > >  			goto drop;
> > >
> > > -		if (x->props.mode == XFRM_MODE_TUNNEL) {
> > > +		if (x->props.mode == XFRM_MODE_TUNNEL ||
> > > +		    x->props.mode == XFRM_MODE_BEET) {
> > >  			decaps = 1;
> > >  			break;
> > >  		}
> >
> > I was under the impression that one of the main points of BEET is that
> > it offers tunnel semantics but does only transport mode processing.
> > Its necessary for inter-family tunnels, but shouldn't this be avoided
> > for normal use?
>
> Yes, this is actually quite a nice improvement to the interfamily
> processing I (at least) haven't thought of before. Tested it & works fine
> (ipv4-ipv4).

It's been a while, but as a fyi in case there are comments / suggestions 
before submitting the whole patch again - it seems that this had some 
problems after all. Works ok for normal cases, but fails when using ip 
options for the inner packet as they don't get processed after being 
extracted from the pseudoheader. Calling something like ip_options_compile 
from beet_mode's input when handling ipv4 would do the trick, but seems a bit 
ugly & perhaps unsafe, I'd rather just put the whole packet through the loop 
again.

br, j
