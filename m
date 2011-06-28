From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 23:46:37 +0200
Message-ID: <20110628214637.GE2121496@jupiter.n2.diac24.net>
References: <20110628150257.GB126252@jupiter.n2.diac24.net>
 <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
 <20110628160018.GC126252@jupiter.n2.diac24.net>
 <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
 <20110628185811.GA2121496@jupiter.n2.diac24.net>
 <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net>
 <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
 <20110628210434.GD2121496@jupiter.n2.diac24.net>
 <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nick Carter <ncarter100@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41682 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab1F1Vqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:46:47 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2011 at 10:22:53PM +0100, Nick Carter wrote:
> > I beg to differ, there very much is. You never ever ever want to be
> > running STP with 802.1X packets passing through... some client will shut
> > down your upstream port, your STP will break and you will die in a fire.
> >
> > The general idea, though, is that a STP-enabled switch is an intelligent
> > switch. And an intelligent switch can speak all those pesky small
> > side-dish protocols.
[...]
> >> > (Some quick googling reveals that hardware switch chips special-drop
> >> > 01:80:c2:00:00:01 [802.3x/pause] and :02 [802.3ad/lacp] and nothing
> >> > else - for the dumb ones anyway. It also seems like the match for pause
> >> > frames usually works on the address, not on the protocol field like we
> >> > do it...)
> >> 'Enterprise' switches drop :03 [802.1x]
> >
> > They also speak STP, see above about never STP+1X :)
> But if you turn off STP they wont start forwarding 802.1x.

Yes, hence my suggestion to have a knob for all of the link-local
ethernet groups. (Which I'm still not actually endorsing, just placing
the idea)

> Also having STP on and forwarding 802.1x would be useful (but
> non-standard) in some cheap redundant periphery switches, connecting
> to a couple of 'core' switches acting as 802.1x authenticators.

That wouldn't really make much sense since those central 802.1X
authenticators wouldn't be able switch the client-facing ports on and
off. Instead, you now have to (1) disable the port switching to make
sure your upstreams stay on and (2) deal with 802.1X clients being
re"routed" by STP to different authenticators that don't know them.


-David

