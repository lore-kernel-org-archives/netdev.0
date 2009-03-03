From: sdrb <sdrb@onet.eu>
Subject: sky2 and skge issue
Date: Tue, 03 Mar 2009 14:35:37 +0100
Message-ID: <49AD3229.6020105@onet.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080807080305000301060004"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4m5.poczta.onet.pl ([213.180.138.35]:48117 "EHLO
	smtp4m5.poczta.onet.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbZCCNfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 08:35:48 -0500
Received: from ip-83-238-22-2.netia.com.pl ([83.238.22.2]:58214 "EHLO
	neostrada.pl" rhost-flags-OK-FAIL-OK-FAIL) by ps4.mod5.onet
	with ESMTPSA id S196180AbZCCNfouhk-S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 14:35:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080807080305000301060004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Hello,

Recently we've been trying to set up 2 bonding interfaces with Intel 
E1000/pro and 2 other ethernet cards for which we've been using skge and 
sky2 drivers. During configuration with ifenslave we've noticed some 
calltrace in system logs:

----calltrace begin-----
e1000e: Intel(R) PRO/1000 Network Driver - 0.5.8.2-NAPI
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:0a:00.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
e1000e 0000:0a:00.0: setting latency timer to 64
0000:0a:00.0: : Failed to initialize MSI interrupts.  Falling back to 
legacy interrupts.
ACPI: Power Button (CM) [PWRB]
0000:0a:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fd
0000:0a:00.0: eth0: Intel(R) PRO/1000 Network Connection
0000:0a:00.0: eth0: MAC: 1, PHY: 4, PBA No: d57995-004
e1000e 0000:0a:00.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
e1000e 0000:0a:00.1: setting latency timer to 64
0000:0a:00.1: : Failed to initialize MSI interrupts.  Falling back to 
legacy interrupts.
0000:0a:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fc
0000:0a:00.1: eth1: Intel(R) PRO/1000 Network Connection
0000:0a:00.1: eth1: MAC: 1, PHY: 4, PBA No: d57995-004
e1000e 0000:09:00.0: PCI INT B -> GSI 18 (level, low) -> IRQ 18
e1000e 0000:09:00.0: setting latency timer to 64
0000:09:00.0: : Failed to initialize MSI interrupts.  Falling back to 
legacy interrupts.
0000:09:00.0: eth2: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:ff
0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
0000:09:00.0: eth2: MAC: 1, PHY: 4, PBA No: d57995-004
e1000e 0000:09:00.1: PCI INT A -> GSI 17 (level, low) -> IRQ 17
e1000e 0000:09:00.1: setting latency timer to 64
0000:09:00.1: : Failed to initialize MSI interrupts.  Falling back to 
legacy interrupts.
0000:09:00.1: eth3: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fe
0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
0000:09:00.1: eth3: MAC: 1, PHY: 4, PBA No: d57995-004
sky2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
sky2 0000:03:00.0: setting latency timer to 64
sky2 0000:03:00.0: v1.22 addr 0xff2fc000 irq 16 Yukon-2 EC rev 2
sky2 eth4: addr 00:1d:60:0e:a2:9e
skge 0000:01:05.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
skge 1.13 addr 0xff0f0000 irq 21 chip Yukon-Lite rev 9
skge eth5: addr 00:1d:60:0e:a0:78
Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
bonding: MII link monitoring set to 50 ms
bonding: bond0 is being deleted...
bonding: bond0 is being created...
bonding: bond0: setting mode to balance-rr (0).
bonding: bond0: Setting MII monitoring interval to 50.
sky2 eth0: enabling interface
bonding: bond0: enslaving eth0 as an active interface with a down link.
skge eth1: enabling interface
bonding: bond0: enslaving eth1 as an active interface with a down link.
bonding: bond0: Unable to set primary slave; bond0 is in mode 0
bonding: bond1 is being created...
bonding: bond1: setting mode to balance-rr (0).
bonding: bond1: Setting MII monitoring interval to 50.
bonding: bond1: enslaving eth2 as an active interface with a down link.
bonding: bond1: enslaving eth3 as an active interface with a down link.
proc_dir_entry '16/eth4' already registered
Pid: 7984, comm: ifenslave Not tainted 2.6.27.10 #72
  [<c01b5d77>] proc_register+0xe7/0x100
  [<c01b5f2e>] proc_mkdir_mode+0x2e/0x50
  [<c015619d>] register_handler_proc+0x6d/0x80
  [<c0154d38>] setup_irq+0xf8/0x1b0
  [<e8f86f30>] e1000_intr+0x0/0x110 [e1000e]
  [<c0154f65>] request_irq+0x85/0xa0
  [<e8f87524>] e1000_request_irq+0x74/0xf0 [e1000e]
  [<e8f8901b>] e1000_open+0x7b/0x180 [e1000e]
  [<c0482487>] dev_open+0x87/0xb0
  [<e8fe263c>] bond_enslave+0x19c/0x8f0 [bonding]
  [<e8fe57f0>] bond_do_ioctl+0x0/0x260 [bonding]
  [<e8fe5a34>] bond_do_ioctl+0x244/0x260 [bonding]
  [<c0485905>] netdev_run_todo+0x35/0x140
  [<c04bf987>] devinet_ioctl+0x407/0x520
  [<c0481d37>] __dev_get_by_name+0x67/0x80
  [<e8fe57f0>] bond_do_ioctl+0x0/0x260 [bonding]
  [<c0484fd6>] dev_ifsioc+0x106/0x290
  [<c0485231>] dev_ioctl+0xd1/0x1e0
  [<c047791c>] sock_ioctl+0xfc/0x1f0
  [<c0477820>] sock_ioctl+0x0/0x1f0
  [<c018539c>] vfs_ioctl+0x5c/0x70
  [<c01855bc>] do_vfs_ioctl+0x4c/0x140
  [<c0185700>] sys_ioctl+0x50/0x60
  [<c0103a52>] syscall_call+0x7/0xb
  [<c0510000>] init_chipset_pdc202xx+0x30/0xd0
  =======================
bonding: bond1: enslaving eth4 as an active interface with a down link.
bonding: bond1: enslaving eth5 as an active interface with a down link.
bonding: bond1: Unable to set primary slave; bond1 is in mode 0
e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
bonding: bond1: link status definitely up for interface eth2.
e1000e: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
bonding: bond1: link status definitely up for interface eth5.
----calltrace end-----



I think the most important line is: "proc_dir_entry '16/eth4' already 
registered".

As we can see in that dump log above - sky2 driver registered new 
network device as "eth4" while loading with insmod:
     sky2 eth4: addr 00:1d:60:0e:a2:9e

Then this name has been changed to "eth0":
     sky2 eth0: enabling interface

I assume that it is because udev changes network device names basing on 
MAC address. Then we get:
     proc_dir_entry '16/eth4' already registered

so it's look like sky2 didn't release interrupt 16 meanwhile udev 
changed name from eth4 to eth0.




I investigated this problem a little. I did some tests on another system 
- and I noticed identical problem with skge driver.

Here there is scenario of reproduction of the problem:

Let's assume that we have device 0x11ab:0x4320 and proper entry in udev 
for it:

# PCI device 0x11ab:0x4320 (skge)
SUBSYSTEM=="net", DRIVERS=="?*", ATTRS{address}=="00:1d:60:0e:a0:a4", 
NAME="eth1"


after:
     # insmod skge.ko


we have following logs:

skge 0000:01:05.0: found PCI INT A -> IRQ 10
skge 1.13 addr 0xfe8ec000 irq 10 chip Yukon-Lite rev 9
skge eth0: addr 00:1d:60:0e:a0:a4


so the driver registered "eth0" but later udev changed it to eth1:

   # cat /proc/interrupts  |grep eth
     10:          0          0    XT-PIC-XT        uhci_hcd:usb3, eth1

   # ifconfig  -a
   eth1      Link encap:Ethernet  HWaddr 00:1D:60:0E:A0:A4
	    BROADCAST MULTICAST  MTU:1500  Metric:1
	    RX packets:0 errors:0 dropped:0 overruns:0 frame:0
	    TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
	    collisions:0 txqueuelen:1000
	    RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
	    Interrupt:10


So we have "eth1" on interrupt 10, but if we do:

   # find /proc/irq/ -name 'eth*'
   /proc/irq/10/eth0

we still have "eth0" (should be "eth1") connected to interrupt 10.


The same effect we can achieve with manual changing name of interface 
(instead of using udev):

     # ifconfig eth1 down
     # ip link set eth1 name eth111
     # ifconfig eth1 up



For *testing only purposes* I've made some patch which enables 
interrupts not just after "insmod" but after "ifconfig ethX up" and 
disables interrupts after "ifconfig ethX down". It is attached to this 
email.

With this patch - when we do

     # ifconfig eth1 down
     # ip link set eth1 name eth111
     # ifconfig eth1 up

it doesn't keep old name of ethX in /proc/irq/*.

I compared this driver with e1000e-0.5.8.2 for intel e1000e, and
there after "ifconfig ethX down" they free interrupt handler, and
"ifconfig ethX up" register it again.


What do you think about this - is it possible to change behaviour of 
sky2 and skge to the same as in e1000e?


regards,
sdrb


--------------080807080305000301060004
Content-Type: text/x-patch;
 name="skge.c4.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="skge.c4.diff"

--- skge.c.orig	2008-12-23 11:11:58.000000000 +0100
+++ skge.c	2009-03-03 13:19:55.249359585 +0100
@@ -2559,6 +2559,10 @@ static void skge_qset(struct skge_port *
 	skge_write32(hw, Q_ADDR(q, Q_DA_L), (u32)base);
 }
 
+
+static irqreturn_t skge_intr(int, void *);
+
+
 static int skge_up(struct net_device *dev)
 {
 	struct skge_port *skge = netdev_priv(dev);
@@ -2640,6 +2644,14 @@ static int skge_up(struct net_device *de
 	spin_unlock_irq(&hw->hw_lock);
 
 	napi_enable(&skge->napi);
+
+	printk("enabling irq_: %d\n",hw->pdev->irq);
+        err = request_irq(hw->pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
+	if (err) {
+	    dev_err(&hw->pdev->dev, "%s: cannot assign irq %d\n", dev->name, hw->pdev->irq);
+	    goto free_rx_ring;
+        }
+
 	return 0;
 
  free_rx_ring:
@@ -2649,6 +2661,9 @@ static int skge_up(struct net_device *de
 	pci_free_consistent(hw->pdev, skge->mem_size, skge->mem, skge->dma);
 	skge->mem = NULL;
 
+
+
+
 	return err;
 }
 
@@ -2735,6 +2750,12 @@ static int skge_down(struct net_device *
 	kfree(skge->tx_ring.start);
 	pci_free_consistent(hw->pdev, skge->mem_size, skge->mem, skge->dma);
 	skge->mem = NULL;
+	
+	
+	printk("disabling irq_: %d\n",hw->pdev->irq);
+	free_irq(hw->pdev->irq, hw);
+		
+	
 	return 0;
 }
 
@@ -3963,12 +3984,14 @@ static int __devinit skge_probe(struct p
 		goto err_out_free_netdev;
 	}
 
+#if 0
 	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "%s: cannot assign irq %d\n",
 		       dev->name, pdev->irq);
 		goto err_out_unregister;
 	}
+#endif
 	skge_show_addr(dev);
 
 	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {
@@ -4030,7 +4053,9 @@ static void __devexit skge_remove(struct
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
 	skge_write8(hw, B0_CTST, CS_RST_SET);
 
+#if 0
 	free_irq(pdev->irq, hw);
+#endif	
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	if (dev1)

--------------080807080305000301060004--
