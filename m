From: "John W. Linville" <linville@tuxdriver.com>
Subject: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Mon, 31 Jul 2006 08:30:44 -0400
Message-ID: <20060731123038.GA10138@tuxdriver.com>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4882 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751106AbWGaMbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 08:31:31 -0400
To: Christophe Devriese <Christophe.Devriese@eurid.eu>
Content-Disposition: inline
In-Reply-To: <200607311015.40255.Christophe.Devriese@eurid.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 10:15:40AM +0200, Christophe Devriese wrote:

> If you bond 2 vlan subinterfaces, the patch is not necessary at all. In that 
> case also the source device will be changed from eth0.<vlan> to bond<x>. So 
> that's correct behavior no ?
> 
> In the second case, you create vlan subifs on a bonding device, vlan 
> subinterfaces will be created on the slave interfaces. In that case the vlan 

(This is not directed at Christophe, or anyone in particular...)

<rant>

Am I the only one that thinks that our handling of LAN L2 stuff
is at best a little "too" flexible (and at worst a collection of
nasty hacks)?

I mean, do we really need both the ability to bond multiple vlan
interfaces AND the ability to have vlan interfaces on top of a bond?
How many people really appreciate the subtle(?) differences?

Then throw bridging into the mix!  If I'm using VLANs and bonds in
a bridged environment, do I bridge the bonds, or bond the bridges?
Do the VLANs come before the bonds?  after the bridges?  or somewhere
in-between?  Do all these combinations even work together?  Who has
the definitive answer (besides the code itself)?

I have no doubt that there are plenty of opportunities for cleverness
here (and no doubt dragons too).  I just doubt that most of them
are worth the complexities introduced by our current collection of
"transparently" stackable pseudo-drivers and strategically placed hacks
(e.g. skb_bond).  All that, and it still isn't clear to me how we
can cleanly accomodate 802.1s (which adds VLAN awareness to bridging).

Do we hold the view that our L2 code is on par with the rest of
our code?  Is there an appetite for a clean-up?  Or is it just me?

</rant>

If you made it this far, thanks for listening...I feel better now. :-)

John
-- 
John W. Linville
linville@tuxdriver.com
