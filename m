From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: iproute2 / tbf with large burst seems broken again
Date: Mon, 24 Aug 2009 15:07:13 +0300
Message-ID: <200908241507.13504.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45566 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbZHXMQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 08:16:53 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id ABD2A1A448C
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 15:09:43 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems something related to the changes with resolution. I remember something 
like this happened before, and i report about it, but i am not able to find 
in mail archives. It seems packets queueing and not passing shaper, if burst 
is set to large value.

Kernel 2.6.30.4 was ok.

uname -a
Linux PPPoE_146 2.6.31-rc7-build-0046-32bit #6 SMP Sun Aug 23 03:51:14 EEST 
2009 i686 GNU/Linux

PPPoE_146 ~ # tc -s -d qdisc show dev ppp87;sleep 10;tc -s -d qdisc show dev 
ppp87
qdisc prio 1: root bands 3 priomap  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 Sent 47980 bytes 367 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 357p requeues 0
qdisc tbf 2: parent 1:1 rate 96000bit burst 2000Kb/8 mpu 0b lat 500.0ms
 Sent 47580 bytes 357 pkt (dropped 0, overlimits 376 requeues 0)
 rate 384bit 1pps backlog 0b 357p requeues 0
qdisc tbf 3: parent 1:2 rate 1024Kbit burst 2000Kb/8 mpu 0b lat 500.0ms
 Sent 400 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc ingress ffff: parent ffff:fff1 ----------------
 Sent 21342 bytes 347 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc prio 1: root bands 3 priomap  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 Sent 48410 bytes 372 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 362p requeues 0
qdisc tbf 2: parent 1:1 rate 96000bit burst 2000Kb/8 mpu 0b lat 500.0ms
 Sent 48010 bytes 362 pkt (dropped 0, overlimits 381 requeues 0)
 rate 448bit 1pps backlog 0b 362p requeues 0
qdisc tbf 3: parent 1:2 rate 1024Kbit burst 2000Kb/8 mpu 0b lat 500.0ms
 Sent 400 bytes 10 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc ingress ffff: parent ffff:fff1 ----------------
 Sent 21692 bytes 352 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

PPPoE_146 ~ # cat /proc/net/psched
000003e8 00000040 000f4240 3b9aca00
