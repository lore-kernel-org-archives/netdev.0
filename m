From: linux@horizon.com
Subject: arp-scan triggers via-velocity "eth0: excessive work at interrupt"
Date: 12 Jun 2007 21:56:38 -0400
Message-ID: <20070613015638.31637.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:16027 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751905AbXFMCDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 22:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It kind of surprised me that sending 254 arp packets by using the arp-scan
tool (http://www.nta-monitor.com/tools/arp-scan/) on a /24 consistently
triggers a burst of "eth0: excessive work at interrupt."

This is a 600 MHz PIII, 2.6.22-rc4, via-velocity driver.

model name      : Pentium III (Katmai)
stepping        : 3
cpu MHz         : 601.406
cache size      : 512 KB

00:09.0 Ethernet controller [0200]: VIA Technologies, Inc. VT6120/VT6121/VT6122 Gigabit Ethernet Adapter [1106:3119] (rev 11)

Just double-checking... the program actually sent 463 packets (256 +
a retry to all those that didn't respond to the first one), and triggers
11 copies of the kernel message.

Command line: arp-scan -I eth0 -l [-v]
