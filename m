From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [PATCH 0/4] atlx: add atl2 support
Date: Tue, 9 Sep 2008 20:58:23 -0500
Message-ID: <20080909205823.4d733492@osprey.hogchain.net>
References: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net, csnook@redhat.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:36972 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbYIJB6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 21:58:50 -0400
Received: by gxk9 with SMTP id 9so12485923gxk.13
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 18:58:49 -0700 (PDT)
In-Reply-To: <20080909061247.GA17834@file.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Sep 2008 02:12:47 -0400
Chris Snook <csnook@redhat.com> wrote:

> This patchset adds support for atl2 hardware to the atlx codebase.
> It is functionally very similar to the out-of-tree 2.0.4 version that
> many distros have been shipping for a few months, though it adds a
> fix from Atheros to fix the problem of device resets under heavy
> bidirectional load.
> 
> The code needs a lot of janitorial work, and there's a lot of
> low-hanging fruit for merging similar atl1 code into the shared atlx
> code, but I think that work will go much faster once this is
> in-tree.  The driver is known to work well for laptop and desktop
> use.  The only major bugs are device initialization problems that
> manifest themselves immediately and obviously (the NIC doesn't work)
> with certain motherboards.

Good job. Haven't spena a lot of time with it, but after the two patchs
provided elswhere, the driver builds cleanly and seems to work with my
Core2 Duo setup running 2.6.27-rc5 on an Asus P5X-ML.

lspci -vvxxx
03:00.0 Ethernet controller: Attansic Technology Corp. L2 100 Mbit Ethernet Adapter (rev a0)
	Subsystem: Attansic Technology Corp. L2 100 Mbit Ethernet Adapter
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 16 bytes
	Interrupt: pin A routed to IRQ 1276
	Region 0: Memory at dbfc0000 (64-bit, non-prefetchable) [size=256K]
	Expansion ROM at dbfa0000 [disabled] [size=128K]
	Capabilities: <access denied>
	Kernel driver in use: atl2
	Kernel modules: atl2
00: 69 19 48 20 06 04 10 00 a0 00 00 02 04 00 00 00
10: 04 00 fc db 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 69 19 48 20
30: 00 00 fa db 40 00 00 00 00 00 00 00 0b 01 00 00

jcliburn@osprey:/proc$ cat /proc/interrupts
           CPU0       CPU1       
  0:         66          0   IO-APIC-edge      timer
  1:       3973          0   IO-APIC-edge      i8042
  4:         10          0   IO-APIC-edge      serial
  6:          5          0   IO-APIC-edge      floppy
  7:          0          0   IO-APIC-edge      parport0
  8:          1          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:        115      57091   IO-APIC-edge      i8042
 14:      24813          0   IO-APIC-edge      ata_piix
 15:          0          0   IO-APIC-edge      ata_piix
 17:          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
 18:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
 19:       1387          0   IO-APIC-fasteoi   uhci_hcd:usb5, HDA Intel
 20:          0          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb2
 23:       4227      32298   IO-APIC-fasteoi   ata_piix
1276:       2636          0   PCI-MSI-edge      eth1
NMI:          0          0   Non-maskable interrupts
LOC:     219900     218553   Local timer interrupts
RES:       4619       5277   Rescheduling interrupts
CAL:       7098       7434   function call interrupts
TLB:       1404       1361   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
SPU:          0          0   Spurious interrupts
