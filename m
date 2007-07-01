From: "=?ISO-8859-1?Q?Thomas_Lang=E5s?=" <thomas.langaas@gmail.com>
Subject: Problem with my network-card, using forcedeth-driver
Date: Mon, 2 Jul 2007 01:22:23 +0200
Message-ID: <6264d2ec0707011622y54b83d82t2de379152f0db647@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:8302 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104AbXGAXWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 19:22:25 -0400
Received: by wa-out-1112.google.com with SMTP id v27so2082997wah
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2007 16:22:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got two boxes, both which uses the forcedeth-driver as the driver
for the network cards.  I've got the same problem on both boxes.  I've
tried various kernels, the latest kernel on my amd64-box is 2.6.22-7
from gutsy (ubuntu).

The problem is as follows:
Once the interface is up, it seems to be working ok, after a little
while with traffic (not much) it becomes "off and on" when it comes to
response.  If my ssh-session has been idle for a minute or two, and I
hit two keys, key number two will be displayed after some sort of
timeout (30 sec -> 1 minute).  Then it becomes reponsive while I use
the session, until I idle again. After a little while with this
behaviour it just becomes totally unresponsive, and I have to restart
the network-device (networking restart) to be able to connect to the
box again.  This is all on eth0.

One of my boxes (amd64-box) is using Asus M2N32-SLI Deluxe as the
motherboard, this has two NICs (same chip on both NICs), and eth1
doesn't have this problem at all, just eth0.  So when eth0 dies, I can
just connect through eth1 and restart the network, and eth0 becomes
responsive again.  But the problem is there still, after a bit.

Since I've had two completely different setups, where one of the few
common factors was the forcedeth.c, and I've seen a few posts around
by other people mentioning the same problems, it seems that the driver
has some bugs or is missing some key functionality for eth0 to become
a usable NIC.

If there's anything I can do to help, please let me know, and I'll
help.  I really want to fix this, so I can use both NICs, and we can
get rid of this error once and for all :-)

This is from lspci, identifying the two NICs:
00:10.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
        Subsystem: ASUSTeK Computer Inc. Unknown device cb84
        Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 509
        Memory at fe02a000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at b400 [size=8]
        Memory at fe029000 (32-bit, non-prefetchable) [size=256]
        Memory at fe028000 (32-bit, non-prefetchable) [size=16]
        Capabilities: [44] Power Management version 2
        Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
        Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+
Queue=0/3 Enable+
        Capabilities: [6c] HyperTransport: MSI Mapping

00:11.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a2)
        Subsystem: ASUSTeK Computer Inc. Unknown device cb84
        Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 508
        Memory at fe027000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at b000 [size=8]
        Memory at fe026000 (32-bit, non-prefetchable) [size=256]
        Memory at fe025000 (32-bit, non-prefetchable) [size=16]
        Capabilities: [44] Power Management version 2
        Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
        Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+
Queue=0/3 Enable+
        Capabilities: [6c] HyperTransport: MSI Mapping

-- 
Thomas
