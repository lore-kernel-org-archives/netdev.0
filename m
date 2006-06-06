From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: NETDEV WATCHDOG: eth2: transmit timed out with 3c905C-TX
Date: Tue, 06 Jun 2006 11:12:45 +0200
Message-ID: <BAY103-F31CD06F5FF6568FC37AFEAB2950@phx.gbl>
References: <20060523205842.GC18008@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f31.bay103.hotmail.com ([65.54.174.41]:65378 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S1750742AbWFFJMr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 05:12:47 -0400
In-Reply-To: <20060523205842.GC18008@bayes.mathematik.tu-chemnitz.de>
To: klassert@mathematik.tu-chemnitz.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steffen Klassert wrote:

>On Tue, May 23, 2006 at 03:36:35PM +0200, Marco Berizzi wrote:
> > Steffen Klassert wrote:
> >
> > >On Wed, Apr 05, 2006 at 06:33:18PM +0200, Marco Berizzi wrote:
> > >> Hello everybody.
> > >> I'm getting these errors (with packet/connectivity loss) on
> > >> our firewall after I have plugged in a 3c905C nic. Linux is
> > >> Slackware 10.2 with vanilla 2.6.16.1.
> > >>
> > >> Hints?
> > >>
> > >> PS: I have temporary resolved the problem running 'ifconfig
> > >> eth2 down' and 'ifconfig eth2 up'
> > >>
> > >> Apr  5 17:47:07 Teti kernel: eth2: Resetting the Tx ring pointer.
> > >> Apr  5 17:47:47 Teti last message repeated 4 times
> > >> Apr  5 17:48:57 Teti last message repeated 7 times
> > >> Apr  5 17:49:57 Teti last message repeated 6 times
> > >> Apr  5 17:50:57 Teti last message repeated 6 times
> > >>
> > >> Apr  5 17:47:07 Teti kernel: NETDEV WATCHDOG: eth2: transmit timed 
>out
> > >
> > >There were some problems of this kind with 10base2 networks in 2.6.16.
> > >Could you please try whether 2.6.17-rc1 has this problems too?
> >
> > [Sorry for the very huge delay, but after 2.6.17-rc1 upgrade
> > xfs filesystem crashed].
> >
> > Same problem here with 2.6.17-rc3-git18. Running ifconfig
> > eth2 down and ifconfig eth2 up resolves the problem for
> > a while.
>
>Actually I have not really an idea what is going on here,
>but increasing the debug level could give some more informations.
>Setting debug=4 is a good start.

I have moved this damn pc from the remote to my site and I have
placed it in production environment with 2.6.17-rc5
No problem after 24 hours (on the remote side the problem was
arising after a couple of hours). I have modprobed 3c59x with
debug=4. I see only these kind of messages (are they fine?):

Jun  5 14:31:25 Pleiadi kernel: eth2: vortex_error(), status=0x8081
Jun  5 14:31:40 Pleiadi last message repeated 3 times
Jun  5 14:31:47 Pleiadi kernel: eth2: vortex_error(), status=0x8281
Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer tick happened, 
Autonegotiate.
Jun  5 14:31:47 Pleiadi kernel: dev->watchdog_timeo=1250
Jun  5 14:31:47 Pleiadi kernel: eth2: MII transceiver has status 782d.
Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer finished, 
Autonegotiate.
Jun  5 14:31:51 Pleiadi kernel: eth2: vortex_error(), status=0x8081
Jun  5 14:32:03 Pleiadi last message repeated 2 times
Jun  5 14:32:10 Pleiadi kernel: eth2: vortex_error(), status=0x8481
Jun  5 14:32:15 Pleiadi kernel: eth2: vortex_error(), status=0x8081
Jun  5 14:32:46 Pleiadi last message repeated 7 times

The only relevant change, between the remote and my site, is a
different ethernet switch where the 3c905C is connected to.
Could it be an issue?

>Did you try older kernel versions too?

I started with 2.6.16.x because I need iptables policy match.


