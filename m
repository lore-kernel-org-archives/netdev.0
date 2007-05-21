From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: socket tx_queue grows and communication stops
Date: Mon, 21 May 2007 13:21:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0705211249190.8578@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:58832 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754914AbXEULVe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 07:21:34 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

writing to both netdev and IrDA since I don't know where the problem 
occurs. More likely in IrDA, but maybe someone from netdev will have 
debugging ideas.

System: PXA270 ARM CPU

Kernel: 2.6.20.1-rt8 (realtime preemption)

Test case: small UDP-packet request-response test over ppp on irnet.

Problem: after some time the tx_queue value in /proc/net/udp for this 
socket on the active (request) side becomes large and the communication 
stops. Whereas background (ppp) IrDA communication runs further, new 
connections are possible. Moreover, the frozen communication can be 
thawed, e.g., if I dump task states per sysrq-t IrDA first reports "no 
activity", but the communication afterwards runs further. Without such a 
kick it hangs indefinitely (days). I think, also just starting a parallel 
ping thaws the socket too. It is hard to reproduce - occurs only after 
several hours of testing (once a day).

So, does anyone have an idea what the reason can be or at least how can I 
debug it? Does it look like a leak again? Nothing suspicious in slabinfo. 
The number in tx_queue doesn't grow gradually - most of the time it's 0.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
