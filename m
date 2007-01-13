From: Pavel Roskin <proski@gnu.org>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sat, 13 Jan 2007 02:45:43 -0500
Message-ID: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_6e71n7pdii9s"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.cesmail.net ([216.154.195.36]:36012 "HELO
	mailgate.cesmail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S965057AbXAMHw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jan 2007 02:52:26 -0500
To: Michael Buesch <mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format.

--=_6e71n7pdii9s
Content-Type: text/plain; charset="ISO-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Michael Buesch <mb@bu3sch.de>:

> > drivers/ssb/driver_mips/mips.c includes asm/time.h, which is missing on
> > x86_64.  It also refers to struct ssb_serial_ports, which is not defined
> > anywhere.
>
> Yeah, CONFIG_SSB_MIPS should depend on the MIPS CPU.
> Which kconfig option do you suggest to make a "depend" on?

I try not to add artificial restrictions.  The driver should depend on the
components providing the necessary API.

It's better to allow compiling the driver for as many configurations as
possible, so that it could be compile tested after massive updates.  It would
also be useful for checking the code with tools like sparse.

It's not hard to come up with more portable alternatives to asm/time.h.

> > drivers/ssb/driver_pci/pcicore.c refers to SSB_PCICORE_SBTOPCI1_CFG1
> > that is not defined anywhere in the kernel.
>
> Yeah, could be a typo. I'll have a look at it.

I only found it because the driver didn't depend on MIPS.  See what I mean?

This only manifests if CONFIG_SSB_PCICORE_HOSTMODE is defined, and it is only
selected by CONFIG_SSB_DRIVER_MIPS.

> Hm, not sure why this oopses. It works on PPC (can transmit data and so on).

My PPC machine is a venerable Blue&White G3, so it won't take PCIe.

> You can disable that. I think that should probably depend
> on CONFIG_SSB_DRIVER_MIPS. I'll take a look.

OK, disabled.

> Does it work with linville's tree (in DMA mode)?

Yes, it does.  I couldn't connect to the AP, but it's a different story.  I may
be doing things wrong.  At least I can scan and I see the APs around.

I'm using an AP with 128-bit WEP.  Setting the key and the ESSID is not
sufficient to associate.  I tried wpa_supplicant, but it won't associate
either.  The kernel messages and the wpa_supplicant output are attached.  I
could not compile wpa_supplicant with MLME (too much code to fix), but I don't
think it should be required.

I tried the current version from your branch without SMP, but it still crashes
in dma_alloc_coherent (also attached).

--
Regards,
Pavel Roskin

--=_6e71n7pdii9s
Content-Type: application/octet-stream; name="wpa_supplicant.output"
Content-Disposition: attachment; filename="wpa_supplicant.output"
Content-Transfer-Encoding: 7bit

# ./wpa_supplicant -Dwext -iwlan0 -cJEDI.conf
ioctl[SIOCSIWMODE]: Device or resource busy
Could not configure driver to use managed mode
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 4 value 0x0 - ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - Trying to associate with 00:0f:66:2f:ef:59 (SSID='JEDI' freq=2437 MHz)
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - ioctl[SIOCSIWMODE]: Device or resource busy
Association request to the driver failed
Authentication with 00:00:00:00:00:00 timed out.
Trying to associate with 00:0f:66:2f:ef:59 (SSID='JEDI' freq=2437 MHz)
ioctl[SIOCSIWAUTH]: Operation not supported
WEXT auth param 5 value 0x1 - ioctl[SIOCSIWMODE]: Device or resource busy
Association request to the driver failed
Authentication with 00:00:00:00:00:00 timed out.

--=_6e71n7pdii9s
Content-Type: text/x-log; charset="ISO-8859-1"; name="d80211.log"
Content-Disposition: attachment; filename="d80211.log"
Content-Transfer-Encoding: 7bit

ACPI: PCI Interrupt 0000:0c:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:0c:00.0 to 64
ssb: Core 0 found: cc 0800, rev 11, vendor 4243
ssb: Core 1 found: cc 0812, rev 0A, vendor 4243
ssb: Core 2 found: cc 0817, rev 03, vendor 4243
ssb: Core 3 found: cc 0820, rev 01, vendor 4243
bcm43xx_d80211: Broadcom 4311 WLAN found
ssb: Switching to core 3
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: Detected PHY: Version: 4, Type 2, Revision 8
bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
bcm43xx_d80211: Radio turned off
bcm43xx_d80211: Radio turned off
wmaster0: Selected rate control algorithm 'simple'
bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 8, MAC: 00:19:7d:21:7b:50)
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: firmware revision 15F, patchlevel 7E, date 2006-07-29 05:54:02
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Radio turned on
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 32-bit DMA initialized
bcm43xx_d80211: Selected 802.11 core (phytype 2)
wmaster0: Does not support passive scan, disabled
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authenticate with AP 00:0f:66:2f:ef:59
wlan0: authentication with AP 00:0f:66:2f:ef:59 timed out
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
warning: many lost ticks.
Your time source seems to be instable or some driver is hogging interupts
rip _spin_unlock_irqrestore+0xb/0xd
Falling back to HPET
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
wlan0: starting scan
wlan0: scan completed
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Using hardware based encryption for keyidx: 0, mac: ff:ff:ff:ff:ff:ff
bcm43xx_d80211: Radio turned off
ssb: Switching to core 0
bcm43xx_d80211: DMA-32 0x0200 (RX) max used slots: 1/64
ssb: Switching to core 1
bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 2/128
bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
bcm43xx_d80211: Virtual interface removed (type: 0x00000002, ID: 8, MAC: 00:19:7d:21:7b:50)

--=_6e71n7pdii9s
Content-Type: application/octet-stream;
	name="bcm43xx_d80211-oops-dma-nosmp"
Content-Disposition: attachment; filename="bcm43xx_d80211-oops-dma-nosmp"
Content-Transfer-Encoding: 7bit

ACPI: PCI Interrupt 0000:0c:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:0c:00.0 to 64
ssb: Sonics Silicon Backplane found on PCI device 0000:0c:00.0
ssb: Core 0 found: ChipCommon (cc 0x800, rev 0x11, vendor 0x4243)
ssb: Core 1 found: IEEE 802.11 (cc 0x812, rev 0x0A, vendor 0x4243)
ssb: Core 2 found: USB 1.1 Host (cc 0x817, rev 0x03, vendor 0x4243)
ssb: Core 3 found: PCI-E (cc 0x820, rev 0x01, vendor 0x4243)
ssb: Switching to ChipCommon core, index 0
ssb: Switching to PCI-E core, index 3
ssb: PCIcore in client mode found
wmaster0: Selected rate control algorithm 'simple'
ssb: Switching to IEEE 802.11 core, index 1
ssb: Switching to PCI-E core, index 3
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Adding Interface type 2
bcm43xx_d80211: Found PHY: Version 4, Type 2, Revision 8
bcm43xx_d80211: Found Radio: Manuf 0x17F, Version 0x2050, Revision 2
bcm43xx_d80211: Loading firmware version 351.126 (2006-07-29 05:54:02)
ssb: Switching to ChipCommon core, index 0
ssb: Switching to IEEE 802.11 core, index 1
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: FIXME: Possibly broken code in bcm43xx_phy_initg() at /home/proski/src/linux-2.6/drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1650
bcm43xx_d80211: Chip initialized
Unable to handle kernel NULL pointer dereference at 0000000000000000 RIP: 
 [<ffffffff8021e9ac>] dma_alloc_coherent+0x52/0x23f
PGD 699e067 PUD 5df0067 PMD 0 
Oops: 0000 [1] 
CPU 0 
Modules linked in: bcm43xx_d80211 ssb
Pid: 2929, comm: ip Not tainted 2.6.20-rc3 #10
RIP: 0010:[<ffffffff8021e9ac>]  [<ffffffff8021e9ac>] dma_alloc_coherent+0x52/0x23f
RSP: 0018:ffff810006b31bf8  EFLAGS: 00010206
RAX: 0000000000000000 RBX: 0000000000003500 RCX: 00000000000010d4
RDX: 00000000ffffffff RSI: 0000000000001000 RDI: ffff8100065fc3a8
RBP: 00000000000010d0 R08: ffff81001f6d1600 R09: 0000000000000004
R10: 0000000000000001 R11: ffff810001147a20 R12: 0000000000001000
R13: ffff81001b836800 R14: ffff8100065fc3a8 R15: 00000000ffffffff
FS:  00002b11e9bdd7f0(0000) GS:ffffffff8056c000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000006ba5000 CR4: 00000000000006e0
Process ip (pid: 2929, threadinfo ffff810006b30000, task ffff81000f0a38a0)
Stack:  ffff81001f2afb40 ffff81001f2afb68 ffff81001b836800 0000000000003500
 ffff81001f2afb40 0000000000000080 ffff81001b836800 0000000000000000
 0000000000000000 ffffffff8801a95e ffff810000000005 0000000100000036
Call Trace:
 [<ffffffff8801a95e>] :bcm43xx_d80211:bcm43xx_setup_dmaring+0x1a7/0x460
 [<ffffffff80250161>] cache_alloc_refill+0x162/0x471
 [<ffffffff8801ae9b>] :bcm43xx_d80211:bcm43xx_dma_init+0xc0/0x290
 [<ffffffff88009131>] :bcm43xx_d80211:bcm43xx_wireless_core_init+0x78f/0x9f1
 [<ffffffff8020dab8>] __alloc_pages+0x5a/0x2a1
 [<ffffffff8800af1c>] :bcm43xx_d80211:bcm43xx_add_interface+0x67/0xeb
 [<ffffffff804420f8>] ieee80211_open+0x1c6/0x2c4
 [<ffffffff80408bef>] dev_open+0x2e/0x6c
 [<ffffffff8040750f>] dev_change_flags+0x5a/0x119
 [<ffffffff8042e57d>] devinet_ioctl+0x235/0x59b
 [<ffffffff804004a6>] sock_ioctl+0x1c8/0x1e5
 [<ffffffff80238f2a>] do_ioctl+0x1b/0x50
 [<ffffffff8022a82a>] vfs_ioctl+0x215/0x227
 [<ffffffff80242166>] sys_ioctl+0x3c/0x5c
 [<ffffffff80250ede>] system_call+0x7e/0x83


Code: 4c 23 38 49 39 d7 0f 46 e9 49 8d 44 24 ff 83 ca ff 49 89 c5 
RIP  [<ffffffff8021e9ac>] dma_alloc_coherent+0x52/0x23f
 RSP <ffff810006b31bf8>
CR2: 0000000000000000
 

--=_6e71n7pdii9s--
