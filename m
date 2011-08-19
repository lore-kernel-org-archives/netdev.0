From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC] bridge: allow passing link-local multicast
Date: Fri, 19 Aug 2011 04:27:31 +0200
Message-ID: <20110819022731.GC180151@jupiter.n2.diac24.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
 <CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
 <20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
 <CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
 <20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
 <CAEJpZP0fOydMMbgquAud7dfwcO28BXAMzAwnMjSZO6TvEjxgpQ@mail.gmail.com>
 <20110818081019.4b9bb79e@nehalam.ftrdhcpuser.net>
 <CAEJpZP2FGhPmTi0+eS+QRhj4y+aqfQHnEUrjmOOLHUay1SuAKg@mail.gmail.com>
 <20110818093941.5ebf716b@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Carter <ncarter100@gmail.com>,
	Ed Swierk <eswierk@bigswitch.com>, netdev@vger.kernel.org,
	David Lamparter <equinox@diac24.net>,
	bridge@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55110 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab1HSC1n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2011 22:27:43 -0400
Content-Disposition: inline
In-Reply-To: <20110818093941.5ebf716b@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 18, 2011 at 09:39:41AM -0700, Stephen Hemminger wrote:
> On Thu, 18 Aug 2011 16:52:45 +0100
> Nick Carter <ncarter100@gmail.com> wrote:
> 
> > On 18 August 2011 16:10, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > > On Thu, 18 Aug 2011 16:06:19 +0100
> > > Nick Carter <ncarter100@gmail.com> wrote:
> > >
> > >> Why can't we use the 802.1D specified STP group address to identify ?
> > >> The existing code uses that address.
> > >> I know you said on another thread that there are people using other addresses.
> > >> Who are these people ?
> > >> Are they following any standard ?
> > >> What address / address range are they using ?
> > >
> > > The group address can be reprogrammed, and it is settable on other
> > > routing equipment. People do it to create spanning tree domains.

I just checked my hardware switches. Neither my Cisco devices nor my HP
ProCurves can reprogram the spanning tree address.

Can you provide an example? Even Linux can't do this, can it?

> > But before the new
> > +               if (!is_stp_bpdu(skb) && br_forward_link_local)
> > check, we have already checked
> > 	if (unlikely(is_link_local(dest))) {
> > So the frame must have a link local destination.  If the reprogrammed
> > group address is outside of the link local range then the new code in
> > this patch will never be hit.  If the reprogrammed group address is in
> > the link local range then i'd suggest my previous group_fwd_mask patch
> > is cleaner and more flexible.
> 
> The problem is that the group_fwd_mask is specific to the address
> not the protocol.

Until corrected, I would consider either match a valid option, and I
would say Nick's patch is much cleaner than yours.

Also, you're arguing against yourself, saying that matching the address
is a problem, but the code you're proposing does exactly that - it first
matches the address (is_link_local()), then the protocol. (wtf?)


-David

