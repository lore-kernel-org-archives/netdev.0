From: "Mr. Berkley Shands" <bshands@exegy.com>
Subject: forcedeth lockup in 2.6.21.5 and 2.6.22-rc6
Date: Tue, 26 Jun 2007 09:45:47 -0500
Message-ID: <4681269B.8090208@exegy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
To: Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [209.83.156.2] ([209.83.156.2]:2682 "EHLO service.eng.exegy.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750827AbXFZOpu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 10:45:50 -0400
Received: from HANAFORD.eng.exegy.net (hanaford.eng.exegy.net [10.19.1.4])
	by service.eng.exegy.net (8.13.1/8.13.1) with ESMTP id l5QEjmxH020670
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2007 09:45:48 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With Centos-5.0/Redhat 5.0 on multiple motherboards (Tyan 2995/ 
SuperMicro H8DCE)
The forcedeth network driver locks up under heavy NFS traffic (32KB frames)
such as linking shared libraries. It either gives a register dump
on a lock up in the transmit side, or loops complaining about
eth0: too many iterations (6) in nv_nic_irq
The system is hung. I cannot get to /var/log/messages, and only dmesg gives
information. "service network restart" or even reloading the 
forcedeth.ko module
does not restore the link. The only fix is "reboot -f".

These machines are 4GB or 8GB opteron workstations. There is no problem
when using 2.6.20. The error counts reported by ifconfig usually show
framing errors, sometimes > 10 digits worth concurrent with this issue
(after being up 5 minutes). I can reproduce this 100% of the time with
2.6.21.5 and 2.6.22-rc6.

Any clues on what to try next?

berkley

-- 

// E. F. Berkley Shands, MSc//

** Exegy Inc.**

349 Marshall Road, Suite 100

St. Louis , MO  63119

Direct:  (314) 218-3600 X450

Cell:  (314) 303-2546

Office:  (314) 218-3600

Fax:  (314) 218-3601

 

The Usual Disclaimer follows...
 
This e-mail and any documents accompanying it may contain legally privileged and/or confidential information belonging to Exegy, Inc. Such information may be protected from disclosure by law. The information is intended for use by only the addressee. If you are not the intended recipient, you are hereby notified that any disclosure or use of the information is strictly prohibited. If you have received this e-mail in error, please immediately contact the sender by e-mail or phone regarding instructions for return or destruction and do not use or disclose the content to others.
