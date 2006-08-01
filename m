From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup
	behavior for VLAN interfaces
Date: Mon, 31 Jul 2006 21:39:08 -0400
Message-ID: <1154396348.5170.43.camel@jzny2>
References: <44CA34D0.1070507@candelatech.com>
	 <44CA87C5.1060905@candelatech.com>
	 <20060730.205032.130618331.davem@davemloft.net>
	 <200607311015.40255.Christophe.Devriese@eurid.eu>
	 <20060731123038.GA10138@tuxdriver.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:39886 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030388AbWHABjQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 21:39:16 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G7jE9-0007zK-Ns
	for netdev@vger.kernel.org; Mon, 31 Jul 2006 21:39:21 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060731123038.GA10138@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-31-07 at 08:30 -0400, John W. Linville wrote:
> On Mon, Jul 31, 2006 at 10:15:40AM +0200, Christophe Devriese wrote:
> 
> > If you bond 2 vlan subinterfaces, the patch is not necessary at all. In that 
> > case also the source device will be changed from eth0.<vlan> to bond<x>. So 
> > that's correct behavior no ?
> > 
> > In the second case, you create vlan subifs on a bonding device, vlan 
> > subinterfaces will be created on the slave interfaces. In that case the vlan 
> 
> (This is not directed at Christophe, or anyone in particular...)
> 
> <rant>
> 
> Am I the only one that thinks that our handling of LAN L2 stuff
> is at best a little "too" flexible (and at worst a collection of
> nasty hacks)?
> 
> I mean, do we really need both the ability to bond multiple vlan
> interfaces AND the ability to have vlan interfaces on top of a bond?
> How many people really appreciate the subtle(?) differences?
> 
> Then throw bridging into the mix!  If I'm using VLANs and bonds in
> a bridged environment, do I bridge the bonds, or bond the bridges?
> Do the VLANs come before the bonds?  after the bridges?  or somewhere
> in-between?  Do all these combinations even work together?  Who has
> the definitive answer (besides the code itself)?
> 
> I have no doubt that there are plenty of opportunities for cleverness
> here (and no doubt dragons too).  I just doubt that most of them
> are worth the complexities introduced by our current collection of
> "transparently" stackable pseudo-drivers and strategically placed hacks
> (e.g. skb_bond).  All that, and it still isn't clear to me how we
> can cleanly accomodate 802.1s (which adds VLAN awareness to bridging).
> 
> Do we hold the view that our L2 code is on par with the rest of
> our code?  Is there an appetite for a clean-up?  Or is it just me?
> 
> </rant>
> 
> If you made it this far, thanks for listening...I feel better now. :-)

Yes, I made it this far and you do make good arguement (or i may be
over-dosed ;->).
I have seen the following setups that are useful:

1) Vlans with bridges; in which one or more vlans exist per ethernet
port. Broadcast packets within such vlans are restricted to just those
vlans by the bridge.
2) complicate the above a little by having multiple spanning trees. 
3) Add to the above link layer HA (802.1ad or otherwise as presented
today by Bonding).

To answer your question; i think yes we need all 3.
Unfortunately the 3 above are all done by different people with
different intentions altogether. I think BGrears end goal was VLANs for
an end host. I think Lennert wrote the original Bridge code and for a
while had some VLAN code that worked well with bridging (that code died
as far as i know). Then bonding - theres some pre-historic relation to
it since D Becker days and then the good folks from Intel adding about
1M features to it. Yes, the fact all 3 need to work together is a
mess ;-> (but there are good pragmatic reasons for them to work
together)...
Hope that helps ;->

cheers,
jamal


