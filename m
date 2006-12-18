From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/5] myri10ge: IRQ and pci state cleanups
Date: Mon, 18 Dec 2006 11:49:12 +0100
Message-ID: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41358 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753842AbWLRLVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:41 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

While testing Stephen Hemminger's patch to cleanup the save/restore_state
in myri10ge, we discovered some problems in our code. First, since the MSI
and PCIe state is saved on a kind of stack, we leak some memory by saving
the state both for parity recovery and on suspend. Additionaly, some race
between the watchdog and the interrupt handler could lead to similar
problems.

We fix all this by first matching the number of pci_save_state() and
pci_restore_state() (#1), then moving request_irq() to myri10ge_open() (#2)
instead of probe() to eliminate some race.
Apart from cleaning the code, this also enables switching from/to MSI
at runtime (#3).
Finally (Stephen's patch), we stop saving the MSI and PCIe states in the
driver since the PCI layer does it for us (#4), and handle some failure
cases in the suspend and resume routines (#5).

1. match number of save_state and restore
2. move request_irq to myri10ge_open
3. make msi configurable at runtime through sysfs
4. no need to save MSI and PCIe state in the driver
5. handle failures in suspend and resume

Thanks,
Brice

