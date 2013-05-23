From: Holger Brunck <holger.brunck@keymile.com>
Subject: napi layer and packet throttling
Date: Thu, 23 May 2013 13:52:46 +0200
Message-ID: <519E030E.5040903@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:59950 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758215Ab3EWMAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 08:00:01 -0400
Received: from frodo.de.keymile.net ([10.9.1.54]:59725 helo=mailrelay.de.keymile.net)
	by mail-de.keymile.com with esmtp (Exim 4.76)
	(envelope-from <Holger.Brunck@keymile.com>)
	id 1UfU4d-0001yA-0v
	for netdev@vger.kernel.org; Thu, 23 May 2013 13:52:47 +0200
Received: from srvdehan1003.de.keymile.net (srvdehan1003.de.keymile.net [10.9.1.108])
	by mailrelay.de.keymile.net (8.12.2/8.12.2) with ESMTP id r4NBonxd013533
	for <netdev@vger.kernel.org>; Thu, 23 May 2013 13:50:49 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I have a general question to the napi layer. I have a board with a MPC8360
processor which uses the ucc_geth.c driver for it's ethernet device. The kernel
version is 3.9. We see in lab tests that the board gets unresponsive if we send
a high packet rate to this ethernet device via an packet generator. In the end
we would like to limit the amount of incoming packets at a very early stage, to
prevent the system of a to high softirq load.

The NAPI layer description I read on:
http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
pointed two main functions out for the napi layer.

a) Interrupt mitigation
Which works perfectly on the ucc_geth.c driver under high load the hard irqs for
the RX packets are disabled and we switch to a polling mode. If the load is more
relaxed we switch back.

b) Packet-Throttling
Here the description says "NAPI-compliant drivers can often cause packets to be
dropped in the network adaptor itself, before the kernel sees them at all."

This is exactly what I need for my usecase. But I don't see any hints how this
can be implemented with the napi layer. So what I need would be something like a
possibility to accept on the eth0 device in timeframe x only packetcount y. If
this packetcount is reached disable hard irq and napi_poll until the timeframe
is expired.

So are there any pointers to other ethernet drivers doing something like this?
Do I misunderstand the packet throttling purpose of the NAPI layer completely?

Any help is appreciated.

Regards
Holger
