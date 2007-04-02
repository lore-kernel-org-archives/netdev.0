From: Christian Kujau <evil@g-house.de>
Subject: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Mon, 2 Apr 2007 20:41:00 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704022012300.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, malte@g-house.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:52605 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965793AbXDBULS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 16:11:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi there,

we have serious problems with 2 of our servers: both shiny new amd64 
dual core, with both 2GB RAM, 32bit kernel+userland (Debian/testing).
Both servers have 2 NICs, RTL8139 (eth0, irq10) and RTL8169s
(eth1, irq11).

Both boxes are running fine but after "a while" they lock up and 
eventually restart all of a sudden. The last messages in the logfile 
are:

14:15:11 db2 kernel: NETDEV WATCHDOG: eth0: transmit timed out
14:15:14 db2 kernel: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1

Then the box reboots, nothing else in the log.

As the servers have been set up recently, we only know that it happend 
with Debian's 2.6.17-? kernel. When we upgraded the installation, we 
went to 2.6.18-4-k7 and the problem persistent. We're using now vanilla 
2.6.20.4 and while the problem persists, it takes longer to lockup (~20h 
as opposed to 4-5h). While this is a good thing for us, it's now harder
to reproduce (we have to wait longer).

Searching the archives turned up quite a few results but no real fix and 
lots of old postings too. We then disabled ACPI completely and booted 
with 'noapic'. Now both boxes are running for > 20h and we're curious 
how long they make it. However, booting with 'noapic' slowed down both 
servers *a lot*.

>From /proc/interrupts we can see that only CPU0 (core 0) is handling 
interrupts while CPU1 does not. We compiled with CONFIG_IRQBALANCE=n so 
that irqbalance(1) would work - but to no avail.

Please see http://nerdbynature.de/bits/2.6.20.4/ for details for both 
hosts and feel free to ask for more details. Although both boxes are in 
production we'll be happy test more bootoptions/patches and the like.

TIA,
Christian.
-- 
BOFH excuse #266:

All of the packets are empty.
