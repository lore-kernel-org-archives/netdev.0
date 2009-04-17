From: Paul Smith <paul@mad-scientist.net>
Subject: bond mode=6: Traffic is uneven across my interfaces... help?
Date: Fri, 17 Apr 2009 16:53:12 -0400
Message-ID: <1240001592.8944.719.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:54826 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752752AbZDQUxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 16:53:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.  Thanks to your help (esp. Jay) I now have my systems coming up
with bonded interfaces.  However, I'm seeing some weird behavior.  I
have 6 systems, each one as I described before: two Broadcom NetXen II
BCM5708S interfaces (bnx2) and two Broadcom NetXen 5714S interfaces
(tg3).  I'm bonding one of the NetXen II with one of the NetXen; the
other two interfaces are not configured (this is for HA reasons).

I am running all the interfaces with MTU 9000.  My tests involve sending
a lot of 9000 byte UDP packets to each system from the other 5, then the
next from the remaining 5, etc. so that after the test all systems have
received and sent about the same amount of traffic to each of the other
systems.  I have a single high-speed switch so these are all on the same
subnet.

The other (possibly) interesting thing is that the MAC addresses on the
interfaces are all set to known and not-very-random values.  The first,
second, third, and fifth octets are identical in all interfaces on all 6
systems.  The fourth octet will be 00, 01, 02, or 03 for each of the
four interfaces (right now 00 is the tg3 and 02 is the bnx2, and we're
not using the other two).  And, the sixth octet will be different for
each system, all odd numbers starting with 1 (so 01, 03, 05, 07, 09,
0B).

The first problem is that if the enslaving happens so that the bond
takes on the MAC (and other attributes?) of the 5708S (bnx2) interface,
then about 98-99% of my traffic goes over only one of the interfaces,
the 5714S (tg3)!  The 5708S is virtually unused.  That's not good.

The second problem is that when the devices are enslaved the other way,
the transmit traffic is distributed more or less evenly (we see anything
from a perfect 50/50 split, to a worst case of 42%/58%) BUT the receive
traffic is really not even close to even: they tend to hover around
36%/64% distribution.

I'm starting to delve into the implementation of the bonding driver,
both bond_main.c and bond_alb.c, but I'm hoping some folks here will
have some comments on this to help direct me (or convince me my task is
hopeless).

Any advice, pointers to code, pointers to documentation, quick
explanations, etc. will be gratefully received...

Cheers!


