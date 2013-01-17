From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: [BUG] "sleeping in invalid" in dev_change_name()
Date: Thu, 17 Jan 2013 11:22:11 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1301171114150.30897@axis700.grange>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:65199 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759491Ab3AQKWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 05:22:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, getting a BUG dump below from a wireless driver, is probably not 
driver specific. Just not seeing it normally, because in most cases the 
name is either the same, or the interface is already up and you get a 
-EBUSY back.

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/

[   63.789062] mmc1: queuing unknown CIS tuple 0x80 (5 bytes)
[   63.789062] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[   63.804687] mmc1: queuing unknown CIS tuple 0x80 (9 bytes)
[   63.804687] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[   63.812500] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[   63.820312] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[   63.820312] mmc1: queuing unknown CIS tuple 0x80 (3 bytes)
[   63.828125] mmc1: queuing unknown CIS tuple 0x80 (5 bytes)
[   63.835937] mmc1: queuing unknown CIS tuple 0x80 (9 bytes)
[   63.843750] mmc1: new SDIO card at address 0001
[   63.851562] b43-sdio mmc1:0001:1: Chip ID 14e4:4318
[   63.851562] ssb: Found chip with id 0x4318, rev 0x02 and package 0x00
[   63.867187] ssb: Core 0 found: ChipCommon (cc 0x800, rev 0x0D, vendor 0x4243)
[   63.875000] ssb: Core 1 found: IEEE 802.11 (cc 0x812, rev 0x09, vendor 0x4243)
[   63.890625] ssb: Core 2 found: PCI (cc 0x804, rev 0x0C, vendor 0x4243)
[   63.890625] ssb: Core 3 found: PCMCIA (cc 0x80D, rev 0x07, vendor 0x4243)
[   63.906250] b43-phy0: Broadcom 4318 WLAN found (core revision 9)
[   63.960937] b43-phy0: Found PHY: Analog 3, Type 2 (G), Revision 7
[   64.015625] ssb: Sonics Silicon Backplane found on SDIO device mmc1:0001:1
[   64.187500] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   64.203125] BUG: sleeping function called from invalid context at .../linux/mm/slab.c:3179
[   64.210937] in_atomic(): 1, irqs_disabled(): 0, pid: 940, name: udevd
[   64.218750] Backtrace: 
[   64.218750] [<c0012724>] (dump_backtrace+0x0/0x110) from [<c0267c80>] (dump_stack+0x18/0x1c)
[   64.226562]  r6:cf1c6bc0 r5:000000d0 r4:cf000080 r3:60000013
[   64.234375] [<c0267c68>] (dump_stack+0x0/0x1c) from [<c004493c>] (__might_sleep+0xec/0x10c)
[   64.242187] [<c0044850>] (__might_sleep+0x0/0x10c) from [<c008f988>] (__kmalloc_track_caller+0x80/0x188)
[   64.250000] [<c008f908>] (__kmalloc_track_caller+0x0/0x188) from [<c0074dac>] (kstrdup+0x38/0x54)
[   64.257812]  r7:000000d0 r6:cf1c6bc0 r5:00000006 r4:c0199af4
[   64.257812] [<c0074d74>] (kstrdup+0x0/0x54) from [<c0199af4>] (device_rename+0x34/0xa4)
[   64.265625]  r7:c03ca0c0 r6:cf4b9000 r5:cf4b9000 r4:cf4b9218
[   64.273437] [<c0199ac0>] (device_rename+0x0/0xa4) from [<c01eb9f4>] (dev_change_name+0xdc/0x274)
[   64.281250]  r7:c03ca0c0 r6:00000000 r5:cf4b9000 r4:cf504000
[   64.289062] [<c01eb918>] (dev_change_name+0x0/0x274) from [<c01ebd5c>] (dev_ifsioc+0x1d0/0x34c)
[   64.296875] [<c01ebb8c>] (dev_ifsioc+0x0/0x34c) from [<c01ec4a4>] (dev_ioctl+0x5cc/0x748)
[   64.304687]  r7:cf505e70 r6:00000000 r5:00008923 r4:bea7e220
[   64.312500] [<c01ebed8>] (dev_ioctl+0x0/0x748) from [<c01d8954>] (sock_ioctl+0x270/0x2a4)
[   64.320312] [<c01d86e4>] (sock_ioctl+0x0/0x2a4) from [<c00a0f84>] (vfs_ioctl+0x28/0x40)
[   64.328125]  r6:00000003 r5:cf1d4340 r4:bea7e220 r3:c01d86e4
[   64.335937] [<c00a0f5c>] (vfs_ioctl+0x0/0x40) from [<c00a1738>] (do_vfs_ioctl+0x5b0/0x5fc)
[   64.343750] [<c00a1188>] (do_vfs_ioctl+0x0/0x5fc) from [<c00a17c8>] (sys_ioctl+0x44/0x64)
[   64.351562] [<c00a1784>] (sys_ioctl+0x0/0x64) from [<c000ec00>] (ret_fast_syscall+0x0/0x30)
[   64.359375]  r8:c000eda8 r7:00000036 r6:b6fb7d98 r5:b6fcf1a8 r4:b6fcf168
[   84.742187] b43-phy0: Loading OpenSource firmware version 410.31754
[   84.742187] b43-phy0: Hardware crypto acceleration not supported by firmware
