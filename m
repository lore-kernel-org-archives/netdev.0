From: Michael Buesch <mb@bu3sch.de>
Subject: The new SSB subsystem for bcm43xx (and others)
Date: Fri, 22 Dec 2006 13:59:24 +0100
Message-ID: <200612221359.25093.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@nbd.name>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57800
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828AbWLVNAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 08:00:31 -0500
To: bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a development snapshot of the new Sonics Silicon Backplane
subsystem I am currently designing.
A port of the bcm43xx driver is included and it works (more or less).
There are still some things left and broken (most are marked with TODO
or FIXME).

This is just a snapshot for you to look at what it will look
like when it's done. The major API is done. There will be some
minor changes to it, but that's it.

Well, what is this, actually? This subsystem has the goal to make
it possible to drive the mainline kernel with bcm43xx on an
embedded system based on the sonics backplane natively and out of
the box. The Linksys WRT router is a good example for one of these
devices.
There is also a port of b44 available, so it can run on this,
but it's not included here.

In general it works like this:

[Host PCI bus]
      \
[Sonics Backplane]
   \      \     \
bcm43xx   b44   other devices...

The Host PCI bus does not need to be there. In fact, it is
not there for the embedded devices. So the Sonics Backplane is
the main system bus.

The ssb subsystem completely abstracts all these details,
so that we can run the same bcm43xx (and b44) driver on
a normal PCI machine and such an embedded device natively.

In previous implementations the normal bcm43xx PCI driver
was run on these devices, by emulating a PCI bus on top of
the real SSB Bus.

The Quilt series for all this can be downloaded here:
http://bu3sch.de/misc/new-ssb-20061222.tar.bz2

This series applies against my wireless development git tree.

-- 
Greetings Michael.
