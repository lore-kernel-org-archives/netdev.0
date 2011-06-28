From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Tue, 28 Jun 2011 18:00:18 +0200
Message-ID: <20110628160018.GC126252@jupiter.n2.diac24.net>
References: <BANLkTim2G7_pnv5W10Q7kHHCnc2v126fZw@mail.gmail.com>
 <20110623152929.3f94b3e7@nehalam.ftrdhcpuser.net>
 <BANLkTi==Ho+6nCX=0hFEQgNAoNE34g35UA@mail.gmail.com>
 <20110624120859.3c43bbcb@nehalam.ftrdhcpuser.net>
 <BANLkTin4XOCmpFaETsjkYb2kk+psZUBKcA@mail.gmail.com>
 <BANLkTimD+fvhrhpc+kPXt1qMnQvVi2dw=Q@mail.gmail.com>
 <20110628150257.GB126252@jupiter.n2.diac24.net>
 <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:43853 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757597Ab1F1QAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 12:00:30 -0400
Content-Disposition: inline
In-Reply-To: <20110628081015.1b06a3f0@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2011 at 08:10:15AM -0700, Stephen Hemminger wrote:
> On Tue, 28 Jun 2011 17:02:57 +0200
> David Lamparter <equinox@diac24.net> wrote:
> > >  	if (skb) {
> > > +		/* Prevent Crosstalk where a Supplicant on one Port attempts to
> > > +		 * interfere with authentications occurring on another Port.
> > > +		 * (IEEE Std 802.1X-2001 C.3.3)
> > > +		 */
> > > +		if (unlikely(!br->pae_forward &&
> > > +		    skb->protocol == htons(ETH_P_PAE)))
> > 
> > No, please don't.
> > 
> > Linux bridging has two "grand" modes: dumb and STP enabled.
> > 
> > If we're running a dumb bridge, we behave like an ethernet hub without
> > any intelligence, and in that case we should absolutely forward 802.1X
> > frames. We may have (e.g. VM) client(s) that want to authenticate with a
> > physical switch.
> > (For the spec, this counts as "repeater", not "bridge"/"switch")
> > 
> > If we're running with STP enabled, then 802.1X traffic should already be
> > caught by the general ethernet link-local multicast drop (which applies
> > to 01:80:c2:/24 and therefore catches 802.1X too.)
> 
> The problem is that STP is not enabled by default, and most people don't
> know how to enable it.

Yes, the default is a dumb hub (IMHO correctly so). And a dumb hub will
forward 802.1X packets (IMHO also correctly so).

Why should we specifically add a knob for EAPOL? Next we're adding one
for STP itself, then one for LLDP, then one for Cisco's deprecated
crap (CDP, DTP, ...) etc.

If you want a dumb hub that drops EAPOL, use ebtables.

-David

