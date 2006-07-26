From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Update of the r8169 branch
Date: Wed, 26 Jul 2006 23:58:40 +0200
Message-ID: <20060726215840.GA4032@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Randy Dunlap <rdunlap@xenotime.net>,
	Daniel Drake <dsd@gentoo.org>,
	Samir Bellabes <sbellabes@mandriva.com>,
	"Boris B. Zhmurov" <bb@kernelpanic.ru>,
	David Raison <david@ion.lu>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37827 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751197AbWGZWCH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:02:07 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The r8169 branch at git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git
has been replaced by an updated version which should correctly support
the 8168 chipset given Boris and David's feedback.

The previous version of the r8169 branch has been archived as r8169-20060612.

The changes may support some different flavors of the chipset (pci-e 8136
and 8167) but I have not received confirmation nor support request for
those.

The changes are available as a serie of patches too at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc2/r8169

The r8169 branch do not conflict with Jeff's upstream branch (ok, it's
currently merged...).

The changes below are included (against mainline):

commit bcf0bf90cd9e9242b66e0563b6a8c8db2e4c262c

    r8169: sync with vendor's driver
    
    - add several PCI ID for the PCI-E adapters ;
    - new identification strings ;
    - the RTL_GIGA_MAC_VER_ defines have been renamed to closely match the
      out-of-tree driver. It makes the comparison less hairy ;
    - various magic ;
    - the PCI region for the device with PCI ID 0x8136 is guessed.
      Explanation: the in-kernel Linux driver is written to allow MM register
      accesses and avoid the IO tax. The relevant BAR register was found at
      base address 1 for the plain-old PCI 8169. User reported lspci show that
      it is found at base address 2 for the new Gigabit PCI-E 816{8/9}.
      Typically:
      01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.: Unknown device 8168 (rev 01)
              Subsystem: Unknown device 1631:e015
              Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
              Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
              Latency: 0, cache line size 20
              Interrupt: pin A routed to IRQ 16
              Region 0: I/O ports at b800 [size=256]
              Region 2: Memory at ff7ff000 (64-bit, non-prefetchable) [size=4K]
              ^^^^^^^^
      So far I have not received any lspci report for the 0x8136 and
      Realtek's driver do not help: be it under BSD or Linux, their r1000 driver
      include a USE_IO_SPACE #define but the bar address is always hardcoded
      to 1 in the MM case. :o/
    - the 8168 has been reported to require an extra alignment for its receive
      buffers. The status of the 8167 and 8136 is not known in this regard.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit 4ff96fa67379c31ced69f193c7ffba17051f38e8

    r8169: remove rtl8169_init_board
    
    Rationale:
    - its signature is not exactly pretty;
    - it has no knowledge of pci_device_id;
    - kiss 23 lines good bye.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit 623a1593c84afb86b2f496a56fb4ec37f82b5c78

    r8169: hardware flow control
    
    The datasheet suggests that the device handles the hardware flow
    control almost automagically. User report a different story, so
    let's try to twiddle the mii registers.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit 9dccf61112e6755f4e6f154c1794bab3c509bc71

    r8169: RX fifo overflow recovery
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

commit a2b98a697fa4e7564f78905b83db122824916cf9

    r8169: mac address change support
    
    Fix for http://bugzilla.kernel.org/show_bug.cgi?id=6032.
    
    Cc: Tim Mattox <tmattox@gmail.com>
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
