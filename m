From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
	(rmmod BUG)
Date: Fri, 14 Nov 2008 13:38:44 +0100
Message-ID: <1226666324.17392.11.camel@localhost.localdomain>
References: <20081112.041143.11487260.davem@davemloft.net>
	 <1226494179.6834.64.camel@localhost.localdomain>
	 <1226566222.6834.76.camel@localhost.localdomain>
	 <20081113.140824.156293734.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53320 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbYKNMjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 07:39:14 -0500
In-Reply-To: <20081113.140824.156293734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-11-13 at 14:08 -0800, David Miller wrote:
> I suspect that something might be changing np->num_ldg, but
> anyways the following debugging patch should provide some
> clues.  Please reproduce this and send the logs it generates.

Debugging the rmmod problem...

I found a strange behavior, rmmod'ing the niu driver will only cause a
kernel BUG, if the driver was loaded at boot time.  If I remove the
niu.ko driver from /lib/modules/2.6.28-rc4-davem/kernel/drivers/net/
reboot the system.  After that I can load and unload the niu.ko driver
without problems... hmmm

Here is you dmesg output with extra debug statements:
-----------------------------------------------------
niu 0000:0b:00.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
niu: niu_get_parent: platform_type[1] port[3]
niu 0000:0b:00.3: setting latency timer to 64
niu: niu_get_invariants: VPD offset [00016a00]
niu: VPD_SCAN: start[16a14] end[16b98]
niu: VPD_SCAN: Reading in property [local-mac-address] len[6]
niu: VPD_SCAN: Reading in property [version] len[38]
niu: VPD_SCAN: Reading in property [model] len[14]
niu: VPD_SCAN: Reading in property [board-model] len[12]
niu: VPD_SCAN: Reading in property [num-mac-addresses] len[1]
niu: VPD_SCAN: Reading in property [phy-type] len[4]
niu: VPD_SCAN: FCODE major(3) minor(9)
niu: niu_get_and_validate_port: port[3] num_ports[4]
niu: niu_probe_ports(): port_phy[000000aa]
niu: niu_classifier_swstate_init: num_tcam(256)
eth4: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 17, node addr 00:1e:0b:71:60:84
usb 5-2: configuration #1 chosen from 1 choice
udev: renamed network interface eth4 to eth1
hub 5-2:1.0: USB hub found
hub 5-2:1.0: 7 ports detected
usb 5-2: New USB device found, idVendor=03f0, idProduct=1327
usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 5-2: Product: Virtual Hub
usb 5-2: Manufacturer: HP
eth4: NIU Ethernet 00:14:4f:da:17:09
eth4: Port type[BMAC] mode[1G:COPPER] XCVR[MII] phy[mif]
udev: renamed network interface eth1_rename to eth0
udev: renamed network interface eth2 to eth3
udev: renamed network interface eth4 to eth5
udev: renamed network interface eth0_rename to eth2
udev: renamed network interface eth3_rename to eth4
Adding 3903784k swap on /dev/cciss/c0d0p2.  Priority:-1 extents:1 across:3903784k
EXT3 FS on cciss/c0d0p1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on cciss/c0d0p3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
IPv4 FIB: Using LC-trie version 0.408
niu 0000:0b:00.0: niu: eth2: niu_request_irq() num_ldg[13]
niu 0000:0b:00.0: niu: eth2: Request IRQ 32, lp(f62b46d4), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 31, lp(f62b470c), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 30, lp(f62b4744), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 29, lp(f62b477c), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 28, lp(f62b47b4), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 27, lp(f62b47ec), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 26, lp(f62b4824), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 25, lp(f62b485c), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 24, lp(f62b4894), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 23, lp(f62b48cc), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 22, lp(f62b4904), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 21, lp(f62b493c), err=0
niu 0000:0b:00.0: niu: eth2: Request IRQ 20, lp(f62b4974), err=0
niu 0000:0b:00.1: niu: eth3: niu_request_irq() num_ldg[1]
niu 0000:0b:00.1: niu: eth3: Request IRQ 17, lp(f63e46d4), err=0
niu: eth2: Link is up at 1Gb/sec, full duplex
niu: eth3: Link is up at 1Gb/sec, full duplex
bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex
niu: niu_put_parent: port[3]
niu 0000:0b:00.3: PCI INT D disabled
niu: niu_put_parent: port[2]
niu 0000:0b:00.2: PCI INT C disabled
niu 0000:0b:00.1: niu: eth3: niu_free_irq() num_ldg[1]
niu 0000:0b:00.1: niu: eth3: free IRQ 17, lp(f63e46d4)
niu: niu_put_parent: port[1]
niu 0000:0b:00.1: PCI INT B disabled
niu 0000:0b:00.0: niu: eth2: niu_free_irq() num_ldg[13]
niu 0000:0b:00.0: niu: eth2: free IRQ 32, lp(f62b46d4)
niu 0000:0b:00.0: niu: eth2: free IRQ 31, lp(f62b470c)
niu 0000:0b:00.0: niu: eth2: free IRQ 30, lp(f62b4744)
niu 0000:0b:00.0: niu: eth2: free IRQ 29, lp(f62b477c)
niu 0000:0b:00.0: niu: eth2: free IRQ 28, lp(f62b47b4)
niu 0000:0b:00.0: niu: eth2: free IRQ 27, lp(f62b47ec)
niu 0000:0b:00.0: niu: eth2: free IRQ 26, lp(f62b4824)
niu 0000:0b:00.0: niu: eth2: free IRQ 25, lp(f62b485c)
niu 0000:0b:00.0: niu: eth2: free IRQ 24, lp(f62b4894)
niu 0000:0b:00.0: niu: eth2: free IRQ 23, lp(f62b48cc)
niu 0000:0b:00.0: niu: eth2: free IRQ 22, lp(f62b4904)
niu 0000:0b:00.0: niu: eth2: free IRQ 21, lp(f62b493c)
niu 0000:0b:00.0: niu: eth2: free IRQ 20, lp(f62b4974)
------------[ cut here ]------------
kernel BUG at drivers/pci/msi.c:630!
invalid opcode: 0000 [#1] PREEMPT SMP 
last sysfs file: /sys/class/net/lo/operstate
Modules linked in: thermal rng_core hpwdt hpilo serio_raw ehci_hcd uhci_hcd bnx2 zlib_inflate niu(-) processor sr_mod cdrom

Pid: 3153, comm: rmmod Not tainted (2.6.28-rc4-davem #19) ProLiant DL380 G5
EIP: 0060:[<c0230cdc>] EFLAGS: 00010286 CPU: 2
EIP is at msi_free_irqs+0xdc/0xe0
EAX: f61887c0 EBX: 00000030 ECX: f6472694 EDX: c049c680
ESI: f7222000 EDI: f722246c EBP: f590feb4 ESP: f590fea8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process rmmod (pid: 3153, ti=f590e000 task=f718b2c0 task.ti=f590e000)
Stack:
 f7222000 f62b4540 f7222000 f590febc c0230ce8 f590fec8 c0230f71 f62b4000
 f590fedc f81fe678 f7222000 f82033d4 f82033d4 f590fee8 c022bbc9 f7222058
 f590fef8 c027b1a9 f7222058 f7222184 f590ff0c c027b27d f82033a0 f82033d4
Call Trace:
 [<c0230ce8>] ? msix_free_all_irqs+0x8/0x10
 [<c0230f71>] ? pci_disable_msix+0x31/0x40
 [<f81fe678>] ? niu_pci_remove_one+0x88/0x8a [niu]
 [<c022bbc9>] ? pci_device_remove+0x19/0x40
 [<c027b1a9>] ? __device_release_driver+0x59/0x90
 [<c027b27d>] ? driver_detach+0x9d/0xb0
 [<c027a515>] ? bus_remove_driver+0x75/0xa0
 [<c027b729>] ? driver_unregister+0x39/0x40
 [<c022be21>] ? pci_unregister_driver+0x21/0x80
 [<f81fb29d>] ? niu_exit+0xd/0x10 [niu]
 [<c014ce46>] ? sys_delete_module+0x116/0x1f0
 [<c0144309>] ? lock_release_holdtime+0x79/0xc0
 [<c0174df6>] ? sys_munmap+0x46/0x60
 [<c0103231>] ? sysenter_do_call+0x12/0x2c
Code: b7 43 08 8b 53 1c c1 e0 04 01 d0 ba 01 00 00 00 83 c0 0c 89 10 3b 7b 14 75 aa 8b 43 1c e8 dd 77 ee ff eb a0 5b 31 c0 5e 5f 5d c3 <0f> 0b eb fe 55 89 e
5 e8 18 ff ff ff 5d c3 8d b6 00 00 00 00 55 
EIP: [<c0230cdc>] msi_free_irqs+0xdc/0xe0 SS:ESP 0068:f590fea8
---[ end trace 8eed6b3e1ad2a790 ]---


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
