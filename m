From: David Lamparter <equinox@diac24.net>
Subject: Re: [patch net-next-2.6] net: allow multiple rx_handler registration
Date: Tue, 12 Jul 2011 18:03:30 +0200
Message-ID: <20110712160330.GC909183@jupiter.n2.diac24.net>
References: <1310468761-2304-1-git-send-email-jpirko@redhat.com>
 <20110712115422.GD616804@jupiter.n2.diac24.net>
 <20110712132005.GA2300@minipsycho.brq.redhat.com>
 <20110712142937.GA909183@jupiter.n2.diac24.net>
 <20110712150120.GB2300@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net,
	greearb@candelatech.com, mirqus@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38135 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709Ab1GLQDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 12:03:46 -0400
Content-Disposition: inline
In-Reply-To: <20110712150120.GB2300@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 05:01:22PM +0200, Jiri Pirko wrote:
> Tue, Jul 12, 2011 at 04:29:38PM CEST, equinox@diac24.net wrote:
> >On Tue, Jul 12, 2011 at 03:20:08PM +0200, Jiri Pirko wrote:
> >> Not possible. See netdev_set_master(). Anyway, before rx_handler was
> >> introduced, this was possible and no one cared.
> >
> >I don't see how this is related. I'm talking about the other end of your
> >bond. Like for example the 802.3ad capable switch you're bonding to.
> 
> Well it is related in way that you cannot have one device in br an bond
> in same time....

Grah, I was looking at our production kernel tree, which doesn't have
the netdev_set_master calls from the bridging code. Sorry, my fault.

> >> >b) a device having macvlans and being a bond slave
> >> > -> Fully incompatible. Same as above, packets to the macvlan will end
> >> >    up on other bond member devices.

But case b) is still up & alive, macvlan doesn't use netdev_set_master.

> >> This patch doen't introduce anything new which wasn't possible before
> >> rx_handler times. Anyway removing bond from using rx_handler as you
> >> suggested pushes us back.
> >
> >I would actually consider this a regression, if the clashing rx_handler
> >is the only thing that gets bonding an 'exclusive' hold of the device.
> 
> No regression. Regression it would be if something wouldn't work on same
> setup. But this is not the case!

Your patch allows a setup (bond+macvlan) that is not only a violation of
the specification's letters, but will also wreak rather big havoc and
may cause parts of itself to become non-functioning.

What happens when the user does this?:
 eth0 -> bond0
    -> macvlan0 -> bond1

My complaint is primary centering on the inclusion of bonding code into
this. There might be bonding modes where this is acceptable, but in
802.3ad mode this royally breaks things.

> >> And to your idea about multi-bridge support, br co needs to be
> >> adjusted as well. And in relation with PRIO, my idea (inspired from RFC
> >> of this patch comments) is to allow users to change priorities
> >> dynamically from userspace. Also then it could be a range of prios for
> >> bridge for example.
> >
> >Hoping I can convey my point,
> >
> >
> >-David
> >
> >
> >P.S.: Could you please provide some sample usage cases for this feature?
> 
> Converting vlan to rx_handler needs this at least.

Hm, yes. I guess this patch is needed to pave the way. I uphold my fears
about including bonding (read: 802.3ad) in this though. Maybe I should
cook up some code to give 802.3ad an exclusive grip on the slaves?


-David
