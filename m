From: Phil Oester <kernel@linuxace.com>
Subject: bnx2 probe order change from 2.6.21 -> 2.6.24
Date: Thu, 10 Apr 2008 08:44:01 -0700
Message-ID: <20080410154401.GA14486@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:53315
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757439AbYDJPoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 11:44:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies if this has been covered already, but I searched the archives and
couldn't find anything.

I recently upgraded a Dell Poweredge 1950 from 2.6.21 to 2.6.24, and found
that the onboard Broadcom NetXtreme II nics got probed in the reverse order.

2.6.21:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.5.8.1 (May 7, 2007)
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 16, node addr 0015c5eaef1c
ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth9: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 16, node addr 0015c5eaef1e

2.6.24:

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.6.9 (December 8, 2007)
ACPI: PCI Interrupt 0000:08:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 16, node addr 00:15:c5:ea:ef:1e
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16 (level, low) -> IRQ 16
udev: renamed network interface eth8 to eth9
eth8: Broadcom NetXtreme II BCM5708 1000Base-T (B1) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 16, node addr 00:15:c5:ea:ef:1c


Is this known/expected?  Seems somewhat odd from both a MAC address
perspective (1c < 1e) and a PCI bus order (04 < 08).  Thoughts?

Phil
