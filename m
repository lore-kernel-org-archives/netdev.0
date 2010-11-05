From: Thomas Graf <tgraf@infradead.org>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 16:31:50 -0400
Message-ID: <20101105203150.GA12118@canuck.infradead.org>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
 <1288964206.2882.402.camel@edumazet-laptop>
 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
 <20101105142510.GA14986@canuck.infradead.org>
 <1288967665.2882.522.camel@edumazet-laptop>
 <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
 <1288969614.2882.590.camel@edumazet-laptop>
 <OFAA7963DE.C3F04675-ONC12577D2.0056F55C-C12577D2.00575EC2@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:55198 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab0KEUbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 16:31:52 -0400
Content-Disposition: inline
In-Reply-To: <OFAA7963DE.C3F04675-ONC12577D2.0056F55C-C12577D2.00575EC2@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 05, 2010 at 04:54:18PM +0100, Joakim Tjernlund wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 16:06:54:
> >
> > > Hopefully most of that is legacy or just plain wrong? Unless
> > > someone can say why only test IFF_UP one should consider changing them.
> > >
> >
> > Most of the places are hot path.
> >
> > You dont want to replace one test by four tests.
> >
> > _This_ would be wrong :)
> 
> Wrong is wrong, even if it is in the hot path :)
> Perhaps it is time define and internal IFF_OPERATIONAL flag
> which is the sum of IFF_UP, IFF_RUNNING etc.? Tht
> way you still get one test in the hot path and can abstract
> what defines an operational link.

You definitely don't want to have your send() call fail simply because
the carrier was off for a few msec or the routing daemon has put a link
down temporarly. Also, the outgoing interface looked up at routing
decision is not necessarly the interface used for sending in the end.
The packet may get mangled and rerouted by netfilter or tc on the way.

Personally I'm even ok with the current behaviour of sendto() while the
socket is bound to an interface but if we choose to return an error
if the interface is down we might as well do so based on the operational
status.
