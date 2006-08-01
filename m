From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 1 Aug 2006 08:08:41 -0400
Message-ID: <20060801120836.GA29208@tuxdriver.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060731123038.GA10138@tuxdriver.com> <1154396348.5170.43.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3337 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750886AbWHAMJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:09:06 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154396348.5170.43.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 09:39:08PM -0400, Jamal Hadi Salim wrote:
> On Mon, 2006-31-07 at 08:30 -0400, John W. Linville wrote:

> > Do we hold the view that our L2 code is on par with the rest of
> > our code?  Is there an appetite for a clean-up?  Or is it just me?
> > 
> > </rant>
> > 
> > If you made it this far, thanks for listening...I feel better now. :-)
> 
> Yes, I made it this far and you do make good arguement (or i may be
> over-dosed ;->).
> I have seen the following setups that are useful:
> 
> 1) Vlans with bridges; in which one or more vlans exist per ethernet
> port. Broadcast packets within such vlans are restricted to just those
> vlans by the bridge.
> 2) complicate the above a little by having multiple spanning trees. 
> 3) Add to the above link layer HA (802.1ad or otherwise as presented
> today by Bonding).
> 
> To answer your question; i think yes we need all 3.

Oh, don't get me wrong -- I definitely think we need all three.

I'm just not sure we need every conceivable combination of a) bonds
of vlan interfaces; b) vlan interfaces on top of bonds; c) bridged
vlan interfaces w/ disparate vlan IDs; d) bonded vlan interfaces w/
disparate vlan IDs; e) bonded bridge interfaces (does this work?) f)
bonded bonds (seen customers trying to do it); g) bridged vlan
interfaces; h) bridged bonds; i) bridged bridges (probably doesn't
work, but someone probably wants it); j) vlan interfaces on top of
bridges; k) vlan interfaces on top of vlans (double vlan tagging);
and, l) what am I leaving out?

Most (actually all afaik) L2 networking equipment enforces some
hierarchy on the relationship between these L2 entities.  I am more
and more convinced we should do the same, although I do acknowledge
that the current situation does allow for some cleverness.

I'm just not sure that cleverness is worth the headache, especially
since the most clever things usually only work by accident...

> Unfortunately the 3 above are all done by different people with
> different intentions altogether. I think BGrears end goal was VLANs for
> an end host. I think Lennert wrote the original Bridge code and for a
> while had some VLAN code that worked well with bridging (that code died
> as far as i know). Then bonding - theres some pre-historic relation to
> it since D Becker days and then the good folks from Intel adding about
> 1M features to it. Yes, the fact all 3 need to work together is a
> mess ;-> (but there are good pragmatic reasons for them to work
> together)...

I'm sure you are correct -- each entity was developed to serve its
purpose, and each does so admirably on its own.  The fact that they
work together is a desirable miracle.

There is no doubt that we need to be able to do all three (vlan,
bridge, bond) at once.  I'm just not convinced we need to support
stacking them in every conceivable order.  And, I think that a
reconsideration of all three functions as a group could lead to
better/cleaner functionality with easier support for extension (e.g.
802.1s).

Well, I'll guit now before I get sent-off to the visionaries list.
I am putting some thought to this, but I'm not yet far enough along
to sound coherent... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
