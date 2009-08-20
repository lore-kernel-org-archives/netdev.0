From: Frans Pop <elendil@planet.nl>
Subject: e1000e: why does pci_enable_pcie_error_reporting() fail on my hp2510p?
Date: Thu, 20 Aug 2009 17:14:29 +0200
Message-ID: <200908201714.30638.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Xiaotian Feng <dfeng@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:57114 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750815AbZHTPOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 11:14:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the current kernel I suddenly get the following error displayed
during boot:
  e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
  e1000e: Copyright (c) 1999-2008 Intel Corporation.
  e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
! e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb
  e1000e 0000:00:19.0: setting latency timer to 64
  e1000e 0000:00:19.0: irq 26 for MSI/MSI-X

This looks to be the consequence of:
commit 68eac4602b9104cdaa6c18b3edd914cececa6a1e
Author: Xiaotian Feng <dfeng@redhat.com>
Date:   Fri Aug 14 14:35:52 2009 +0000
    e1000e: fix use of pci_enable_pcie_error_reporting

Looking at the change it seems logical that this error, that I previously
only saw during resumes from suppend to RAM, now also shows up during
system boot. So I don't think it can be qualified as a regression, but it
is certainly rather annoying.

Questions:
- is it possible that the error occurs due to a kernel bug, or is this
  certain to be due to broken hardware?
- as the error is non-fatal, should it maybe be changed from dev_err
  to dev_info, so that at least it does not show up during a boot
  with 'quiet'?
- if broken hardware is common, should the kernel complain at all,
  or at least maybe show a slightly "friendlier" message?

System: hp2510p (ICH8, Core2 Duo) running x86_64, Debian stable ("Lenny")

00:19.0 Ethernet controller [0200]: Intel Corporation 82566MM
        Gigabit Network Connection [8086:1049] (rev 03)
    Subsystem: Hewlett-Packard Company Device 30c9
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
    Interrupt: pin A routed to IRQ 26
    Region 0: Memory at e0620000 (32-bit, non-prefetchable) [size=128K]
    Region 1: Memory at e0640000 (32-bit, non-prefetchable) [size=4K]
    Region 2: I/O ports at 2060 [size=32]
    Capabilities: [c8] Power Management version 2
            Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
            Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
            Address: 00000000fee0300c  Data: 41b1
    Kernel driver in use: e1000e
    Kernel modules: e1000e

I can provide full dmesg and kernel config if desired.

Cheers,
FJP
