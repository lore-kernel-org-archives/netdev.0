From: Jay Vosburgh <fubar@us.ibm.com>
Subject: RE: [Bonding-devel] [patch] (2/8) Add 802.3ad support to bonding
Date: Wed, 02 Apr 2003 17:01:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200304030101.h33113tc015107@death.ibm.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>,
   "Marom, Noam" <noam.marom@intel.com>,
   "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	I've been trying various things with the 802.3ad patch, and am
seeing a behavior that seems erroneous, but it could be that I'm
missing something (in the standard, for example) that explains it.

	I have two systems, connected via an 802.3ad capable switch.
System A has 4 10/100 ethernets connected to the switch, which are all
ifenslaved into a single 802.3ad mode bond (with miimon=100).  System
B has a single 10/100 connected to the switch.

	As a traffic generator, I telnet from System A to System B's
chargen service, and let it run.  I see activity on two of the bond's
four links (which is expected, one for incoming, one for outgoing).

	If I unplug either of the active cables from the switch,
bonding notices immediately and transfers the connection to a
different interface.

	If, however, I use "ifenslave -d bond0 ethX" (where ethX is
one of the active interfaces, by which I mean one with traffic flowing
over it), it takes a considerable amount of real time for bonding to
recover and transfer the connection to a new interface.  It appears
that the deleted interface must be either the transmitting or
receiving interface (I'm not sure which), as sometimes it recovers
immediately.  Removing an idle interface from the bond does not appear
to cause any stalls.

	Also, curiously, if I "ifenslave bond0 ethX" where ethX is an
already enslaved interface, I get an EBUSY error printed by ifenslave,
but the data transmission stalls for a period of time.  Presumably
this is due to some of the prepatory work done by ifenslave, but I
have not yet investigated precisely what it is.  Ifenslave also seems
to leave the interface in a down state, which may be the cause of the
stall (if the interface is removed from the bond because it's down).

	Any thoughts?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
