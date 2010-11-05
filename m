From: Thomas Graf <tgraf@infradead.org>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 10:25:10 -0400
Message-ID: <20101105142510.GA14986@canuck.infradead.org>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
 <1288964206.2882.402.camel@edumazet-laptop>
 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:60775 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab0KEOZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 10:25:12 -0400
Content-Disposition: inline
In-Reply-To: <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 05, 2010 at 03:01:57PM +0100, Joakim Tjernlund wrote:
> > > Then I do ifconfig eth1 down
> > > and I still see the same. Should not
> > > sendto and/or revcfrom return some error as
> > > the interface is down?
> >
> > Hmm, this reminds me one patch, yes...
> >
> > Search for " ipv4: remove all rt cache entries on UNREGISTER event"
> >
> > http://permalink.gmane.org/gmane.linux.network/173391
> 
> Ah, that does the trick. A few comments though:
> 
> 1) I think you should include IFF_RUNNING too

Probably even better to base it on the operational state of the link

netif_running() && netif_oper_up() && netif_carrier_ok() && !netif_dormant()
