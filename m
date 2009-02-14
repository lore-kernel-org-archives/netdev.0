From: Michael Tokarev <mjt@tls.msk.ru>
Subject: r8169: instant crash if receiving packet larger than MTU
Date: Sat, 14 Feb 2009 18:16:36 +0300
Message-ID: <4996E054.20905@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:46920 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbZBNPQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Feb 2009 10:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I played with jumbo frames today at home on two
machines with built-in r8169 NICs.  And discovered
that, after enabling larger packets on one machine,
it's sufficient to send SINGLE packet to immediately,
instantly crash the other machine.

I'd say it's quite a serious issue.  Good it usually
can't be triggered "from outside" (from the Internet)
because there, standard 1500-sized MTU is usually
used (or at least in last-mile network segment), but
on LAN it's quite common nowadays to at least HAVE
the jumbo-capable equipment, and that's all what's
needed to trigger this.

Comments?

(The system in question is based on an Asus M3A78-EM
motherboard, here's the lspci info for the NIC:
02:00.0 0200: 10ec:8168 (rev 02)
	Subsystem: 1043:82c6
	Flags: bus master, fast devsel, latency 0, IRQ 509
	I/O ports at e800 [size=256]
	Memory at fbeff000 (64-bit, non-prefetchable) [size=4K]
	Memory at faff0000 (64-bit, prefetchable) [size=64K]
	Expansion ROM at fbec0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
	Capabilities: [70] Express Endpoint, MSI 01
	Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
	Capabilities: [d0] Vital Product Data <?>
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [140] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 81-68-10-ec-00-00-00-00
	Kernel driver in use: r8169
	Kernel modules: r8169
)

Thanks!

/mjt
