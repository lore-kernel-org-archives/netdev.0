From: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Subject: RFC: replace packets already in queue
Date: Thu, 28 Jun 2012 13:18:13 +0000
Message-ID: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailguard.fkie.fraunhofer.de ([128.7.3.5]:37317 "EHLO
	a.mx.fkie.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab2F1Nnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 09:43:53 -0400
Received: from rufsun5.fkie.fgan.de ([128.7.2.5] helo=mailhost.fkie.fraunhofer.de)
	by a.mx.fkie.fraunhofer.de with esmtps (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <ralph.erdt@fkie.fraunhofer.de>)
	id 1SkEbv-0000dX-Eo
	for netdev@vger.kernel.org; Thu, 28 Jun 2012 15:18:15 +0200
Received: from mailserv1.fkie.fgan.de ([128.7.96.101] helo=mailserv1.lorien.fkie.fgan.de)
	by mailhost.fkie.fraunhofer.de with esmtp (Exim 4.72)
	(envelope-from <ralph.erdt@fkie.fraunhofer.de>)
	id 1SkEbv-0000cR-CD
	for netdev@vger.kernel.org; Thu, 28 Jun 2012 15:18:15 +0200
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I've send this email already in the lartc mailing list. Short after this I found the list seems dead (http://dir.gmane.org/gmane.linux.network.routing). I hope this is the correct place to ask. If not - please give me a note, where I can ask this.)

----------

Hello.

I'm writing a kernel module (net/sched) which replaces packets in the queue. I'm glad hearing your option.

Background:
In very low bandwidth network (<=9.6Kbps, shared, etc.) its hard (rather: impossible) to get all packets sent.
But some of the packets contain information, which gets obsolete over time. E.g. (GPS) positions, which will be sent periodically. If the application sends a new packet while an old position packet is still in the queue, the old packet is obsolete. This can be dropped. But just dropping the old packet and queuing the new packet will result in never sending a packet of this type.

So I'm writing a tc-qdisc scheduler module, which replaces packets in the queue on enqueuing, when this properties are given:
- UDPv4
- not fragmented
- (TOS & bitmask) = givenCompare; (bitmask and compare are adjustable)
- same source IP
- same destination IP
- same destination port
- same TOS
So, the packet got sent over the time - but with the actual information.

What do you think? Is this module worth to get released to kernel.org? Have you any other comments?

Greetings
Ralph Erdt
