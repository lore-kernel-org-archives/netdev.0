From: Donald Becker <becker@scyld.com>
Subject: Re: [PATCH] 2.4.20-pre sundance.c cleanups
Date: Thu, 19 Sep 2002 08:58:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209190849020.29420-100000@beohost.scyld.com>
References: <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jason Lunz <lunz@gtf.org>, <netdev@oss.sgi.com>,
   <jgarzik@mandrakesoft.com>, "Patrick R. McManus" <mcmanus@ducksong.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
In-Reply-To: <200209190353.g8J3r5q28456@vindaloo.ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Sep 2002, Richard Gooch wrote:

>   Hi, all. I've just taken the patch Jason released on 28-AUG and
> applied it to 2.4.19. The driver finds my D-Link 580-TX 4-port
> ethercard, and it seems to be running OK. However, I note a few warts:
> 
> - the driver is reporting 10 Mbps rather than 100 Mbps. I've actually
>   measured eth0 and eth2 and these are delivering 100 Mbps
> 
> - I tried to force eth1 to 100 Mbps FD, but I don't know for sure if
>   it's working or not (the switch that eth1 connects to doesn't do
...
> sundance.c:v1.01d 28-Aug-2002  Written by Donald Becker

My 1.01 version released in early 2001.  Perhaps distinguishing this
from my release would be useful.


> eth0: D-Link DFE-580TX 4 port Server Adapter at 0xc000, 00:05:5d:10:4d:b8, IRQ 5.
> eth0: MII PHY found at address 0, status 0x782d advertising 01e1.
> eth0: MII PHY found at address 1, status 0x782d advertising 01e1.

This is wrong.  My driver starts searching for MII PHYs at #1 to avoid
the quirks of accessing a transceiver at #0.

Background: Nominally the #0 transceiver address is reserved for
physically external, plug-in transceiver.  Such an external transceiver
powers up disconnected from the MII data transfer path, and the driver
must explicitly disable all other transceivers and enable #0 to use it.
However in real life you never encounter this situation.  Instead
some non-standard transceivers respond to address #0 as well as their
proper address.  Except that they often don't operate properly when
accessed at #0, so the driver should always use their real MII address.

> eth0: Setting full-duplex based on MII #0 negotiated capability 01e1.
> eth1: Link changed: Autonegotiation advertising 10Mbps full duplex, partner 10Mbps full duplex.
> eth1: Setting full-duplex based on MII #0 negotiated capability 0100.

Yeah, that pretty much points directly to a flaw...

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
