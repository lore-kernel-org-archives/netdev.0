From: Paul Smith <paul@mad-scientist.net>
Subject: 2.6.27.18: bonding: scheduling while atomic
Date: Tue, 05 May 2009 15:14:37 -0400
Message-ID: <1241550877.30571.17.camel@psmith-ubeta.netezza.com>
Reply-To: paul@mad-scientist.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta.netezza.com ([12.148.248.132]:53773 "EHLO netezza.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751675AbZEETOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 15:14:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all;  I got a "scheduling while atomic" error while I was enslaving
my second interface to my bond (balance-alb / mode 6).  I already have
the previous fix for a locking error installed here.

The system did not fail: it continued to work properly, so this isn't a
big deal AFAICT, but I thought you might get some information out of it.
Note that this happened to me just once so far as I know... but often
I'm not watching the console on these systems and since it doesn't
fail...  At any rate, it definitely does not happen every time.  I'll
try to keep a closer eye on this for a while.

Linux 2.6.27.18 + patches.  Bonding eth1 and eth3, where eth1 is a
Broadcom Corporation NetXtreme 5714S Gigabit Ethernet (rev a3) using the
tg3 driver, and eth3 is a Broadcom Corporation NetXtreme II BCM5708S
Gigabit Ethernet (rev 12) using the bnx2 driver.

dmesg says:

<6>tg3.c:v3.94 (August 14, 2008)
<6>tg3 0000:13:04.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
<6>eth0: Tigon3 [partno(BCM95714s) rev 9003 PHY(5714)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:14:5e:3a:06:b0
<6>eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
<6>eth0: dma_rwctrl[76148000] dma_mask[40-bit]
<6>tg3 0000:13:04.1: PCI INT B -> GSI 18 (level, low) -> IRQ 18
<6>eth1: Tigon3 [partno(BCM95714s) rev 9003 PHY(5714)] (PCIX:133MHz:64-bit) 1000Base-SX Ethernet 00:14:5e:3a:06:b1
<6>eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
<6>eth1: dma_rwctrl[76148000] dma_mask[40-bit]
<6>TCP cubic registered
<6>NET: Registered protocol family 17
<6>RPC: Registered udp transport module.
<6>RPC: Registered tcp transport module.
<6>Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.8.5b (Feb 9, 2009)
<6>bnx2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
<6>eth2: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 133MHz found at mem da000000, IRQ 17, node addr 00:06:72:00:01:09
<6>bnx2 0000:06:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
<6>eth3: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 133MHz found at mem d8000000, IRQ 19, node addr 00:06:72:01:01:09
<6>ipmi message handler version 39.2
<6>IPMI System Interface driver.
<6>ipmi_si: Trying SMBIOS-specified kcs state machine at i/o address 0xc28, slave address 0x20, irq 0
<6>ipmi: Found new BMC (man_id: 0x000002,  prod_id: 0x000d, dev_id: 0x20)
<6>IPMI kcs interface initialized
<6>ipmi device interface
<6>tg3: eth0: Link is up at 1000 Mbps, full duplex.
<6>tg3: eth0: Flow control is on for TX and on for RX.
<6>tg3: eth0: Link is down.
<6>tg3: eth0: Link is up at 1000 Mbps, full duplex.
<6>tg3: eth0: Flow control is on for TX and on for RX.
<6>tg3: eth1: Link is up at 1000 Mbps, full duplex.
<6>tg3: eth1: Flow control is on for TX and on for RX.
<6>bnx2: eth2: using MSI
<6>bnx2: eth2 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
<6>bnx2: eth3: using MSI
<6>tg3: eth1: Link is down.
<6>tg3: eth1: Link is up at 1000 Mbps, full duplex.
<6>bnx2: eth3 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
<3>bnx2: eth2 NIC SerDes Link is Down
<6>tg3: eth1: Flow control is on for TX and on for RX.
<6>bnx2: eth2 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
<6>Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
<6>bonding: xor_mode param is irrelevant in mode adaptive load balancing
<5>bonding: In ALB mode you might experience client disconnections upon reconnection of a link if the bonding module updelay parameter (0 msec) is incompatible with the forwarding delay time of the switch
<6>bonding: MII link monitoring set to 200 ms
<6>bonding: bond0: enslaving eth1 as an active interface with a down link.
<6>tg3: eth1: Link is up at 1000 Mbps, full duplex.
<6>tg3: eth1: Flow control is on for TX and on for RX.
<6>bonding: bond0: link status definitely up for interface eth1.
<6>bonding: bond0: making interface eth1 the new active one.
<6>bonding: bond0: first active interface up!
<6>bnx2: eth3: using MSI
<3>BUG: scheduling while atomic: ifenslave/1520/0x10000002
<6>bnx2: eth3 NIC SerDes Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
<4>Modules linked in: rng_core dock scsi_mod libata ata_piix zlib_inflate bnx2 ipmi_msghandler ipmi_si ipmi_devintf bonding
<4>Pid: 1520, comm: ifenslave Not tainted 2.6.27.18-dirty #1
<4>
<4>Call Trace:
<4> [<ffffffff8049f52a>] schedule+0xea/0x336
<4> [<ffffffff803a73db>] account+0xbb/0x120
<4> [<ffffffff80237537>] __cond_resched+0x17/0x40
<4> [<ffffffff8049fe85>] _cond_resched+0x35/0x50
<4> [<ffffffff80431915>] rt_cache_flush+0x115/0x120
<4> [<ffffffff8045b465>] arp_netdev_event+0x35/0x40
<4> [<ffffffff802580f7>] notifier_call_chain+0x37/0x70
<4> [<ffffffff8041ad36>] dev_set_mac_address+0x76/0x80
<4> [<ffffffffa00acdb4>] alb_set_slave_mac_addr+0x34/0x90 [bonding]
<4> [<ffffffff8046f32c>] packet_notifier+0x8c/0x1f0
<4> [<ffffffffa00ad0a8>] bond_alb_init_slave+0x228/0x250 [bonding]
<4> [<ffffffffa00a766a>] bond_enslave+0x7ca/0x9d0 [bonding]
<4> [<ffffffff804a1981>] _spin_unlock_irq+0x11/0x40
<4> [<ffffffff8041896a>] __dev_get_by_name+0x9a/0xc0
<4> [<ffffffffa00a8af5>] bond_do_ioctl+0x3f5/0x530 [bonding]
<4> [<ffffffff802580f7>] notifier_call_chain+0x37/0x70
<4> [<ffffffff8041896a>] __dev_get_by_name+0x9a/0xc0
<4> [<ffffffff8041c003>] dev_ioctl+0x343/0x5e0
<4> [<ffffffff8046042b>] devinet_ioctl+0x29b/0x7b0
<4> [<ffffffff802928f7>] handle_mm_fault+0x237/0x940
<4> [<ffffffff8040ade1>] sock_ioctl+0x71/0x260
<4> [<ffffffff802bdebf>] vfs_ioctl+0x2f/0xb0
<4> [<ffffffff802be1a3>] do_vfs_ioctl+0x263/0x2e0
<4> [<ffffffff802be2d7>] sys_ioctl+0xb7/0x100
<4> [<ffffffff802eb2d8>] bond_ioctl+0x118/0x130
<4> [<ffffffff802eb05a>] ethtool_ioctl+0x9a/0xa0
<4> [<ffffffff802ec063>] compat_sys_ioctl+0x113/0x3c0
<4> [<ffffffff8040ca19>] sys_socket+0x69/0x110
<4> [<ffffffff8022ae18>] ia32_syscall_done+0x0/0x21
<4>
<4>bonding: bond0: Warning: the hw address of slave eth3 is in use by the bond; giving it the hw address of eth1
<6>bonding: bond0: enslaving eth3 as an active interface with an up link.



