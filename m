From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Fri, 12 Jan 2007 02:25:33 -0500
Message-ID: <1168586733.19023.19.camel@dv>
References: <200701112110.04311.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:57546 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161020AbXALHZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 02:25:38 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H5Gmd-0002j7-Ri
	for netdev@vger.kernel.org; Fri, 12 Jan 2007 02:25:04 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701112110.04311.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Michael!

I've tried the master branch of bcm43xx-wireless-dev.git for the first
time.  The results are not encouraging so far (although I'm quite new to
this chipset).

drivers/ssb/driver_mips/mips.c includes asm/time.h, which is missing on
x86_64.  It also refers to struct ssb_serial_ports, which is not defined
anywhere.

drivers/ssb/driver_pci/pcicore.c refers to SSB_PCICORE_SBTOPCI1_CFG1
that is not defined anywhere in the kernel.

I could send you huge logs, but I think it's already a clear sign that
you didn't compile-test the current tree with CONFIG_SSB_DRIVER_MIPS
enabled.  Things are better if it is disabled.

In case you haven't seen those warnings:

/home/proski/src/linux-2.6/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:843: warning: 'bcm43xx_wireless_core_mark_inactive' defined but not used
/home/proski/src/linux-2.6/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c:3032: warning: 'bcm43xx_bluetooth_coext_enable' defined but not used

I could compile the code, and it even loaded as a module, but the kernel
oopsed once I brought wlan0 up by ifconfig.

bcm43xx_d80211: Adding Interface type 2
bcm43xx_d80211: Found PHY: Version 4, Type 2, Revision 8
bcm43xx_d80211: Found Radio: Manuf 0x17F, Version 0x2050, Revision 2
bcm43xx_d80211: Loading firmware version 351.126 (2006-07-29 05:54:02)
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: FIXME: Possibly broken code in bcm43xx_phy_initg() at /home/proski/src/linux-2.6/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1650
bcm43xx_d80211: Chip initialized
Unable to handle kernel NULL pointer dereference at 0000000000000000 RIP: 
 [<ffffffff8021eee6>] dma_alloc_coherent+0x52/0x23f
PGD 50d1067 PUD 5201067 PMD 0 
Oops: 0000 [1] SMP 
CPU 1 
Modules linked in: bcm43xx_d80211 ssb
Pid: 2623, comm: ifconfig Not tainted 2.6.20-rc3 #5
RIP: 0010:[<ffffffff8021eee6>]  [<ffffffff8021eee6>] dma_alloc_coherent+0x52/0x23f
RSP: 0018:ffff810005127bd8  EFLAGS: 00010206
RAX: 0000000000000000 RBX: 0000000000003500 RCX: 00000000000010d4
RDX: 00000000ffffffff RSI: 0000000000001000 RDI: ffff81000196c3a8
RBP: 00000000000010d0 R08: ffff81001f6d1600 R09: 0000000000000004
R10: 0000000000000001 R11: ffff810001122c60 R12: 0000000000001000
R13: ffff810001b96000 R14: ffff81000196c3a8 R15: 00000000ffffffff
FS:  00002b411b2133b0(0000) GS:ffff810001827440(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000015fdf000 CR4: 00000000000006e0
Process ifconfig (pid: 2623, threadinfo ffff810005126000, task ffff81001f58d180)
Stack:  ffff81001ee6a3c0 ffff81001ee6a3e8 ffff810001b96000 0000000000003500
 ffff81001ee6a3c0 0000000000000080 ffff810001b96000 0000000000000000
 0000000000000000 ffffffff88019966 0000000000000005 0000000100000036
Call Trace:
 [<ffffffff88019966>] :bcm43xx_d80211:bcm43xx_setup_dmaring+0x1a7/0x460
 [<ffffffff88019ea3>] :bcm43xx_d80211:bcm43xx_dma_init+0xc0/0x290
 [<ffffffff88008131>] :bcm43xx_d80211:bcm43xx_wireless_core_init+0x78f/0x9f1
 [<ffffffff8022885e>] mntput_no_expire+0x19/0x77
 [<ffffffff8020a3c3>] do_page_fault+0x40b/0x74a
 [<ffffffff88009f4e>] :bcm43xx_d80211:bcm43xx_add_interface+0x67/0xeb
 [<ffffffff804378d2>] ieee80211_open+0x1c6/0x2c5
 [<ffffffff803fd3ec>] dev_open+0x2f/0x6e
 [<ffffffff803fbcd5>] dev_change_flags+0x5a/0x119
 [<ffffffff80423bab>] devinet_ioctl+0x235/0x59c
 [<ffffffff803f4bef>] sock_ioctl+0x1c8/0x1e5
 [<ffffffff8023b862>] do_ioctl+0x21/0x6b
 [<ffffffff8022b614>] vfs_ioctl+0x25c/0x275
 [<ffffffff8024559b>] sys_ioctl+0x3c/0x5c
 [<ffffffff802548ee>] system_call+0x7e/0x83


Code: 4c 23 38 49 39 d7 0f 46 e9 49 8d 44 24 ff 83 ca ff 49 89 c5 
RIP  [<ffffffff8021eee6>] dma_alloc_coherent+0x52/0x23f
 RSP <ffff810005127bd8>
CR2: 0000000000000000

It's Fedora Core 6 x86_64 on a Dell Latitude with Core 2 Duo and an PCIe
wireless card.  SMP is enabled.  From .config:

CONFIG_BCM43XX_D80211=m
CONFIG_BCM43XX_D80211_PCI=y
CONFIG_BCM43XX_D80211_DEBUG=y
CONFIG_BCM43XX_D80211_DMA=y
CONFIG_BCM43XX_D80211_PIO=y
CONFIG_BCM43XX_D80211_DMA_AND_PIO_MODE=y
# CONFIG_BCM43XX_D80211_DMA_MODE is not set
# CONFIG_BCM43XX_D80211_PIO_MODE is not set
[skip]
CONFIG_SSB=m
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_EXTIF=y
# CONFIG_SSB_DRIVER_MIPS is not set

[root@localhost proski]# lspci -v -s 0c:00.0
0c:00.0 Network controller: Broadcom Corporation BCM4310 UART (rev 01)
        Subsystem: Dell Unknown device 0007
        Flags: bus master, fast devsel, latency 0, IRQ 17
        Memory at efdfc000 (32-bit, non-prefetchable) [size=16K]
        Capabilities: [40] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
        Capabilities: [d0] Express Legacy Endpoint IRQ 0
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [13c] Virtual Channel

[root@localhost proski]# lspci -n -s 0c:00.0
0c:00.0 0280: 14e4:4312 (rev 01)
[root@localhost proski]#

P.S.  Second attempt, this time with "pio=1" parameter.  At least it
didn't crash, but it would not work either:

ACPI: PCI Interrupt 0000:0c:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:0c:00.0 to 64
ssb: Sonics Silicon Backplane found on PCI device 0000:0c:00.0
wmaster0: Selected rate control algorithm 'simple'
bcm43xx_d80211: Adding Interface type 2
bcm43xx_d80211: Found PHY: Version 4, Type 2, Revision 8
bcm43xx_d80211: Found Radio: Manuf 0x17F, Version 0x2050, Revision 2
bcm43xx_d80211: Loading firmware version 351.126 (2006-07-29 05:54:02)
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: FIXME: Possibly broken code in bcm43xx_phy_initg()
at /home/proski/src/linux-2.6/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1650
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: ERROR: This card does not support PIO operation mode.
Please use DMA mode (module parameter pio=0).
bcm43xx_d80211: Radio turned off

-- 
Regards,
Pavel Roskin


