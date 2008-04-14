From: Milan Kocian <milon@wq.cz>
Subject: 4-port pci card (4x Via VT6105) and SIS964 chipset problem
Date: Mon, 14 Apr 2008 18:12:22 +0200
Message-ID: <20080414161221.GC3208@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:35192 "EHLO ntm.vs.lam.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752150AbYDOGjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 02:39:05 -0400
Received: from milon by ntm.vs.lam.cz with local (Exim 4.69)
	(envelope-from <milon@wq.cz>)
	id 1JlRI6-0001WW-BL
	for netdev@vger.kernel.org; Mon, 14 Apr 2008 18:12:22 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello everyone,

after loading of via-rhine module I see:

MMIO do not match PIO [06] (ff != 00)
via-rhine: probe of 0000:02:08.0 failed with error -5
MMIO do not match PIO [06] (ff != 00)
via-rhine: probe of 0000:02:09.0 failed with error -5
MMIO do not match PIO [06] (ff != 6c)
via-rhine: probe of 0000:02:0a.0 failed with error -5

And only one port is functional. So I tried to disable MMIO & PIO
check in via-rhine.c :

/*      while (mmio_verify_registers[i]) {
                int reg = mmio_verify_registers[i++];
                unsigned char a = inb(pioaddr+reg);
                unsigned char b = readb(ioaddr+reg);
                if (a != b) {
                        rc = -EIO;
                        printk(KERN_ERR "MMIO do not match PIO [%02x] "
                               "(%02x != %02x)\n", reg, a, b);
                        goto err_out_unmap;
                }
        }
*/

Now all ports are working. 
And amateurish question: What can happen if it will be deactivated ?
Is this check so important ?

Kernel 2.6.23.10 (IMHO no essential changes in newest kernels). With intel
chipset it works without problem.

lspci:
00:00.0 Host bridge: Silicon Integrated Systems [SiS] 662 Host (rev 01)
00:01.0 PCI bridge: Silicon Integrated Systems [SiS] SiS AGP Port (virtual PCI-to-PCI bridge)
00:02.0 ISA bridge: Silicon Integrated Systems [SiS] SiS964 [MuTIOL Media IO] (rev 36)
00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE] (rev 01)
00:02.7 Multimedia audio controller: Silicon Integrated Systems [SiS] AC'97 Sound Controller (rev a0)
00:03.0 USB Controller: Silicon Integrated Systems [SiS] USB 1.1 Controller (rev 0f)
00:03.1 USB Controller: Silicon Integrated Systems [SiS] USB 1.1 Controller (rev 0f)
00:03.2 USB Controller: Silicon Integrated Systems [SiS] USB 1.1 Controller (rev 0f)
00:03.3 USB Controller: Silicon Integrated Systems [SiS] USB 2.0 Controller
00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI Fast Ethernet (rev 91)
00:06.0 PCI bridge: Hint Corp HB6 Universal PCI-PCI bridge (non-transparent mode) (rev 15)
00:1f.0 PCI bridge: Silicon Integrated Systems [SiS] PCI-to-PCI bridge
01:00.0 VGA compatible controller: Silicon Integrated Systems [SiS] 661/741/760 PCI/AGP or 662/761Gx PCIE VGA Display Adapter (rev 04)
02:08.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 86)
02:09.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 86)
02:0a.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 86)
02:0b.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 86)

Thanks for answers.

-- 
Milan Kocian
