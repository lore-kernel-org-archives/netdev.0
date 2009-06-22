From: Raz <raziebe@gmail.com>
Subject: RFC : Enhancing NAPI ( OFFSCHED NAPI )
Date: Tue, 23 Jun 2009 01:53:18 +0300
Message-ID: <5d96567b0906221553n62a2c8bcyf7502d1e2d7387ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:53816 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbZFVXAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 19:00:20 -0400
Received: by bwz9 with SMTP id 9so3555551bwz.37
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 16:00:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

I designed a new type of scheduler called OFFSCHED - Offline schedular.
OFFSCHED is a platform for assigning tasks to an offloaded processors.
Linux ACPI gives us
the ability to offload a processor. In OFFSCHED , instead of letting
the offloaded processor
halt, we assign it a service. In this case, NAPI.
For full documentation of OFFSCHED see:
https://sos-linux.svn.sourceforge.net/svnroot/sos-linux/offsched/trunk/Documentation/



				OFFSCHED NAPI
			 MSC Concluding Assignment


			     Document Version: 1.0
			     Author: Raz Ben Yehuda
			     Date: 20/09/2008


		

Table of Content


1. Preface....................................................................3
2. NAPI........................................................................3
3. OFFSCHED NAPI.....................................................4
4. Architecture..............................................................5
5. Bibliography .............................................................5


OFFSCHED-NAPI

1. Preface

This document is an reference for comments about OFFSCHED NAPI over
e1000. To understand OFFSCHED please refer to the OFFSCHED.pdf
document.

OFFSCHED NAPI is merely a platform for supporting OFFSCHED traffic shaper or
firewall or CPU isolated server.

Note
OFFSCHED NAPI code is not complete and has many bugs. it is purely
academic research.
OFFSCHED NAPI is split in the 2.6.30-rc2.patch and the offsched_napi.c driver.

2. NAPI

NAPI[1][2] stands for New API. NAPI is a technique for interrupts
mitigation in networking in the Linux kernel. NAPI technique is a simple
polling over incoming packet arrival queue, this eliminates the constant
interrupt processing. By default, Linux uses receive interrupt for packet
processing, and activate NAPI when a certain threshold of number of
incoming packets is reached. This threshold is known as the network
"weight". Only one processor may call dev poll, this is because only a
single processor can get the initial interrupt.

There are some known flaws though with NAPI [2].

1. Latency. In some cases, NAPI may introduce additional software IRQ
latency.

2. IRQ Masking. On some devices, changing the IRQ mask may be a slow
operation, or require additional locking. This overhead may negate
any performance benefits observed with NAPI.

3. Rotting Packet. In some cases a packet may rot in the RX ring of the
device. This happens due to a race between the time we decide we have
no packet in the RX ring and the time we are forced to enable
interrupts.

3. OFFSCHED NAPI
OFFSCHED NAPI is aimed to solve the above problems.


1. Latency Problem
Very much like NAPI, it will process incoming packets from RX ring. Unlike
NAPI, spinning processors will have very little latency (if any) so
disabling RX interrupts entirely is possible, this way we eliminate both
problems. In addition, there is no need for the initial interrupt (an
interrupt that triggers NAPI).


2. IRQ masking
The duration of the operation of IRQ masking is not a problem because it is
done only once. Once IRQ masking is complete, OFFSCHED NAPI is not bothered
with it again.


3. Rotting Packet
Because we never enable interrupts but continuously spin over the network
devices, this problem does no longer exist.

4.
<>


5. Bibliography
[1] http://en.wikipedia.org/wiki/New_API
[2] http://www.linuxfoundation.org/en/Net:NAPI
[3] Mel Gorman. "Understanding the Linux Virtual Memory Manager" Prentice
Hall , 2004
