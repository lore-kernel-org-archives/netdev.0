From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: TCP IPv4 strange retransmits
Date: Tue, 04 Mar 2008 14:00:56 +0100
Message-ID: <47CD4808.1050202@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:54742 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764720AbYCDM7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 07:59:50 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.3.58])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0JX7008QYIROEI60@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 04 Mar 2008 13:59:49 +0100 (CET)
Received: from [137.226.12.120]
 (informatik-4-137-226-12-120.una.RWTH-Aachen.DE [137.226.12.120] (may be
 forged))	by relay.rwth-aachen.de (8.13.7/8.13.3/1)
 with ESMTP id m24Cxmit012736	for <netdev@vger.kernel.org>; Tue,
 04 Mar 2008 13:59:48 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm observing some retransmits with kernel 2.6.24.2, which I don't understand.
For instance in this cutout[1] of a sequence diagram which was captured[2]
on the TCP sender, 4 retransmits are made.
According to netstat -st output[3][4] all those 4 retransmits were "fast retransmit".
But there are no three DUPACKs which I expected would be needed for fast retransmit?

Also interesting all retransmits happen _after_ those segments were
already acked and sacked, internal queuing or latency issues?

It would be great if somebody could shed some light on this,
why those segments are retransmitted.
Dumps and xplots are available here[5].

Scenario details:

192.168.0.5 <---------------\ /------------------> 192.168.0.7
	                     |
   [ tc qdisc add dev wldev root netem delay 10ms reorder 25% ]
                             |
                             |
                         192.168.0.6

192.168.0.5 establishes connection to 192.168.0.7 via 192.168.0.6.
Then bulk tcp transfer was performed from 192.168.0.5 to 192.168.0.6 for 500 ms.
Default tcp configuration of 2.6.24.2 was used (cc=cubic).


Best regards,
Arnd

[1] http://www.umic-mesh.net/~hannemann/strange-reorder/strange_reorder.png
[2] http://www.umic-mesh.net/~hannemann/strange-reorder/sender.dump
[3] http://www.umic-mesh.net/~hannemann/strange-reorder/netstat-sender.before
[4] http://www.umic-mesh.net/~hannemann/strange-reorder/netstat-sender.after
[5] http://www.umic-mesh.net/~hannemann/strange-reorder/

