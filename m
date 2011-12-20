From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2 3/3] netem: extend man page for rate extension
Date: Tue, 20 Dec 2011 22:28:48 +0100
Message-ID: <1324416528-3845-4-git-send-email-hagen@jauu.net>
References: <1324416528-3845-1-git-send-email-hagen@jauu.net>
Cc: shemminger@vyatta.com, Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42976 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752232Ab1LTV3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:29:20 -0500
In-Reply-To: <1324416528-3845-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 man/man8/tc-netem.8 |   66 ++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
index c8ed292..ef2a63b 100644
--- a/man/man8/tc-netem.8
+++ b/man/man8/tc-netem.8
@@ -3,90 +3,96 @@
 NetEm \- Network Emulator
 .SH SYNOPSIS
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ limit
 packets
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ logging
 LEVEL ]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ delay
 TIME [ JITTER [CORRELATION]]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ distribution
 {uniform|normal|pareto|paretonormal} ]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ drop
 PERCENT [CORRELATION]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ loss
 PERCENT [CORRELATION]]
 .B ]
 
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ query ] [ loss_GI
 ploss [burst_length [density [pisol [good_burst_length]]]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ query ] [ loss_4state
 [p13 [p31 [p32 [p23 [p14]]]]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ loss_gilb_ell
 p [r [1-h [1-k]]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ loss_gilb_ell_4s
 p [r [1-h [1-k]]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem [ loss_pattern
 FILENAME [REPETITIONS]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ corrupt
 PERCENT [CORRELATION]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ duplicate
 PERCENT [CORRELATION]]
 .B ]
 
 .B tc qdisc ... dev
-dev
+DEVICE
 .B ] add netem  [ reorder
 PRECENT [CORRELATION] [ gap DISTANCE ]]
 .B ]
 
+.B tc qdisc ... dev
+DEVICE
+.B ] add netem  [ rate
+RATE [PACKETOVERHEAD [CELLSIZE [CELLOVERHEAD]]]]
+.B ]
+
 .SH DESCRIPTION
 NetEm is an enhancement of the Linux traffic control facilities
 that allow to add delay, packet loss, duplication and more other
@@ -240,6 +246,38 @@ other packets are delayed by 10 ms
 in this second example 25% of packets are sent immediately (with correlation of
 50%) while the other are delayed by 10 ms.
 
+
+.B rate
+RATE [PACKETOVERHEAD [CELLSIZE [CELLOVERHEAD]]]
+
+delay packets based on packet size and is a replacement for TBF. Rate can be
+specified in common units (e.g. 100kbit). Optional PACKETOVERHEAD (in bytes)
+specify an per packet overhead and can be negative. A positive value can be
+used to simulate additional link layer headers. A negative value can be used to
+artificial strip the Ethernet header (e.g. -14) and/or simulate a link layer
+header compression scheme. The third parameter - an unsigned value - specify
+the cellsize. Cellsize can be used to simulate link layer schemes. ATM for
+example has an payload cellsize of 48 bytes and 5 byte per cell header. If a
+packet is 50 byte then ATM must use two cells: 2 * 48 bytes payload including 2
+* 5 byte header, thus consume 106 byte on the wire.  The last optional value
+CELLOVERHEAD can be used to specify per cell overhead - for our ATM example 5.
+CELLOVERHEAD can be negative, but use negative values with caution.
+
+Note that rate throttling is limited by several factors: the kernel clock
+granularity avoid a perfect shaping at a specific level. This will show up in
+an artificial packet compression (bursts). Another influence factor are network
+adapter buffers which can also add artificial delay.
+
+To delay all outgoing packets on devive eth0 with a rate of 5kbit, a per packet
+overhead of 20 byte, a cellsize of 100 byte and a per celloverhead of 5 byte:
+
+tc qdisc add dev eth0 root netem rate 5kbit 20 100 5
+
+And show:
+
+tc qdisc show dev eth0
+
+
 .SH LIMITATIONS
 The main known limitation of Netem are related to timer granularity, since
 Linux is not a real-time operating system; to the choice of Pseudo-Random
-- 
1.7.7.3
