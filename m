From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: Ethernet: how to disable gigabit support
Date: Fri, 6 Feb 2015 11:01:02 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1502061049370.22715@eddie.linux-mips.org>
References: <20150205202527.GA7917@amd>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Received: (from localhost user: 'macro', uid#1010) by eddie.linux-mips.org
        with ESMTP id S27012271AbbBFLBChevQd (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Fri, 6 Feb 2015 12:01:02 +0100
In-Reply-To: <20150205202527.GA7917@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Feb 2015, Pavel Machek wrote:

> This happened on more than one project: there's gigabit-capable chip,
> but the connector is not designed for gigabit speed.
> 
> I'd like to have speed autonegotiation, but not offer gigabit (as it
> will not work).
> 
> Is there way to do that without hacking the kernel? Should mii-tool do
> that?

 It used to work for me with a 3Com 3c905C adapter when I needed to force 
full duplex for an old non-negotiating 100baseTx-FD network switch.

> root@ib8315:~# mii-tool.net-tools  -A 100baseTx,10baseT eth1
> restarting autonegotiation...
> root@ib8315:~# [32432.443883] libphy: mdio@e0024520:01 - Link is Down
> 
> root@ib8315:~# [32435.447863] libphy: mdio@e0024520:01 - Link is Up - 1000/Full
> 
> root@ib8315:~# mii-tool.net-tools -v eth1
> eth1: negotiated 1000baseT-FD flow-control, link ok
> product info: vendor 00:01:c1, model 3 rev 1
> basic mode:   autonegotiation enabled
>  basic status: autonegotiation complete, link ok
>  capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD
>  advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD
>  link partner: 1000baseT-FD 100baseTx-FD 100baseTx-HD
>  10baseT-FD 10baseT-HD flow-control
>  root@ib8315:~# mii-tool.net-tools -V
>  $Id: mii-tool.c,v 1.9 2006/09/27 20:59:18 ecki Exp $
>  (Author: David Hinds based on Donald Becker's mii-diag)
>  net-tools 1.60
>  root@ib8315:~#

 You may have to spell out media names in full, e.g.:

# mii-tool -A 100baseTx-FD,100baseTx-HD,10baseT-FD,10baseT-HD eth1

Also the driver may have a way to override the capabilities advertised via 
a module parameter.  This is what I eventually ended up with with the 
3c905C adapter.

  Maciej
