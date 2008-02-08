From: Brian Haley <brian.haley@hp.com>
Subject: Broadcom 5708 taking a few seconds to get link-up
Date: Fri, 08 Feb 2008 14:29:37 -0500
Message-ID: <47ACADA1.1090809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:31402 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757547AbYBHT3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 14:29:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

I'm working on a system that has two on-board 5708's.  We've noticed 
that it takes about 3 seconds for the link to come up - is this 
considered normal?  I've tried this with the latest davem tree with 
similar results to older kernels/drivers.

# uname -r
2.6.24

# ethtool -i eth3
driver: bnx2
version: 1.7.3
firmware-version: 1.9.3
bus-info: 0000:42:00.0

# lspci -v
42:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708 
Gigabit Ethernet (rev 11)
         Subsystem: Hewlett-Packard Company Unknown device 7038
         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 34
         Memory at fa000000 (64-bit, non-prefetchable) [size=32M]
         Capabilities: [40] PCI-X non-bridge device
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable-

# ip link set eth3 up; mii-tool eth3; sleep 1; mii-tool eth3; sleep 1; 
mii-tool eth3; sleep 1; mii-tool eth3
eth3: no link
eth3: no link
eth3: no link
eth3: negotiated 100baseTx-FD, link ok

Other drivers I've tried - e1000 and tg3, get up in < 1 second.  I'm 
asking becuase any packet I try to transmit out this interface before 
link-up never gets out.

Thanks for any info,

-Brian
