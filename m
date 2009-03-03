From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 and skge issue
Date: Tue, 3 Mar 2009 08:02:56 -0800
Message-ID: <20090303080256.53579d0d@nehalam>
References: <49AD3229.6020105@onet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sdrb <sdrb@onet.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758030AbZCCQDP@vger.kernel.org>
In-Reply-To: <49AD3229.6020105@onet.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 03 Mar 2009 14:35:37 +0100
sdrb <sdrb@onet.eu> wrote:

> 
> Hello,
> 
> Recently we've been trying to set up 2 bonding interfaces with Intel 
> E1000/pro and 2 other ethernet cards for which we've been using skge and 
> sky2 drivers. During configuration with ifenslave we've noticed some 
> calltrace in system logs:
> 
> ----calltrace begin-----
> e1000e: Intel(R) PRO/1000 Network Driver - 0.5.8.2-NAPI
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> e1000e 0000:0a:00.0: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> e1000e 0000:0a:00.0: setting latency timer to 64
> 0000:0a:00.0: : Failed to initialize MSI interrupts.  Falling back to 
> legacy interrupts.
> ACPI: Power Button (CM) [PWRB]
> 0000:0a:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fd
> 0000:0a:00.0: eth0: Intel(R) PRO/1000 Network Connection
> 0000:0a:00.0: eth0: MAC: 1, PHY: 4, PBA No: d57995-004
> e1000e 0000:0a:00.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> e1000e 0000:0a:00.1: setting latency timer to 64
> 0000:0a:00.1: : Failed to initialize MSI interrupts.  Falling back to 
> legacy interrupts.
> 0000:0a:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fc
> 0000:0a:00.1: eth1: Intel(R) PRO/1000 Network Connection
> 0000:0a:00.1: eth1: MAC: 1, PHY: 4, PBA No: d57995-004
> e1000e 0000:09:00.0: PCI INT B -> GSI 18 (level, low) -> IRQ 18
> e1000e 0000:09:00.0: setting latency timer to 64
> 0000:09:00.0: : Failed to initialize MSI interrupts.  Falling back to 
> legacy interrupts.
> 0000:09:00.0: eth2: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:ff
> 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
> 0000:09:00.0: eth2: MAC: 1, PHY: 4, PBA No: d57995-004
> e1000e 0000:09:00.1: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> e1000e 0000:09:00.1: setting latency timer to 64
> 0000:09:00.1: : Failed to initialize MSI interrupts.  Falling back to 
> legacy interrupts.
> 0000:09:00.1: eth3: (PCI Express:2.5GB/s:Width x4) 00:15:17:1b:b4:fe
> 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
> 0000:09:00.1: eth3: MAC: 1, PHY: 4, PBA No: d57995-004
> sky2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> sky2 0000:03:00.0: setting latency timer to 64
> sky2 0000:03:00.0: v1.22 addr 0xff2fc000 irq 16 Yukon-2 EC rev 2
> sky2 eth4: addr 00:1d:60:0e:a2:9e
> skge 0000:01:05.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
> skge 1.13 addr 0xff0f0000 irq 21 chip Yukon-Lite rev 9
> skge eth5: addr 00:1d:60:0e:a0:78
> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
> bonding: MII link monitoring set to 50 ms
> bonding: bond0 is being deleted...
> bonding: bond0 is being created...
> bonding: bond0: setting mode to balance-rr (0).
> bonding: bond0: Setting MII monitoring interval to 50.
> sky2 eth0: enabling interface
> bonding: bond0: enslaving eth0 as an active interface with a down link.
> skge eth1: enabling interface
> bonding: bond0: enslaving eth1 as an active interface with a down link.
> bonding: bond0: Unable to set primary slave; bond0 is in mode 0
> bonding: bond1 is being created...
> bonding: bond1: setting mode to balance-rr (0).
> bonding: bond1: Setting MII monitoring interval to 50.
> bonding: bond1: enslaving eth2 as an active interface with a down link.
> bonding: bond1: enslaving eth3 as an active interface with a down link.
> proc_dir_entry '16/eth4' already registered
> Pid: 7984, comm: ifenslave Not tainted 2.6.27.10 #72
>   [<c01b5d77>] proc_register+0xe7/0x100
>   [<c01b5f2e>] proc_mkdir_mode+0x2e/0x50
>   [<c015619d>] register_handler_proc+0x6d/0x80
>   [<c0154d38>] setup_irq+0xf8/0x1b0
>   [<e8f86f30>] e1000_intr+0x0/0x110 [e1000e]
>   [<c0154f65>] request_irq+0x85/0xa0
>   [<e8f87524>] e1000_request_irq+0x74/0xf0 [e1000e]
>   [<e8f8901b>] e1000_open+0x7b/0x180 [e1000e]
>   [<c0482487>] dev_open+0x87/0xb0
>   [<e8fe263c>] bond_enslave+0x19c/0x8f0 [bonding]
>   [<e8fe57f0>] bond_do_ioctl+0x0/0x260 [bonding]
>   [<e8fe5a34>] bond_do_ioctl+0x244/0x260 [bonding]
>   [<c0485905>] netdev_run_todo+0x35/0x140
>   [<c04bf987>] devinet_ioctl+0x407/0x520
>   [<c0481d37>] __dev_get_by_name+0x67/0x80
>   [<e8fe57f0>] bond_do_ioctl+0x0/0x260 [bonding]
>   [<c0484fd6>] dev_ifsioc+0x106/0x290
>   [<c0485231>] dev_ioctl+0xd1/0x1e0
>   [<c047791c>] sock_ioctl+0xfc/0x1f0
>   [<c0477820>] sock_ioctl+0x0/0x1f0
>   [<c018539c>] vfs_ioctl+0x5c/0x70
>   [<c01855bc>] do_vfs_ioctl+0x4c/0x140
>   [<c0185700>] sys_ioctl+0x50/0x60
>   [<c0103a52>] syscall_call+0x7/0xb
>   [<c0510000>] init_chipset_pdc202xx+0x30/0xd0
>   =======================
> bonding: bond1: enslaving eth4 as an active interface with a down link.
> bonding: bond1: enslaving eth5 as an active interface with a down link.
> bonding: bond1: Unable to set primary slave; bond1 is in mode 0
> e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
> bonding: bond1: link status definitely up for interface eth2.
> e1000e: eth5 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
> bonding: bond1: link status definitely up for interface eth5.
> ----calltrace end-----
> 
> 
> 
> I think the most important line is: "proc_dir_entry '16/eth4' already 
> registered".
> 
> As we can see in that dump log above - sky2 driver registered new 
> network device as "eth4" while loading with insmod:
>      sky2 eth4: addr 00:1d:60:0e:a2:9e
> 
> Then this name has been changed to "eth0":
>      sky2 eth0: enabling interface
> 
> I assume that it is because udev changes network device names basing on 
> MAC address. Then we get:
>      proc_dir_entry '16/eth4' already registered
> 
> so it's look like sky2 didn't release interrupt 16 meanwhile udev 
> changed name from eth4 to eth0.
> 
> 
> 
> 
> I investigated this problem a little. I did some tests on another system 
> - and I noticed identical problem with skge driver.
> 
> Here there is scenario of reproduction of the problem:
> 
> Let's assume that we have device 0x11ab:0x4320 and proper entry in udev 
> for it:
> 
> # PCI device 0x11ab:0x4320 (skge)
> SUBSYSTEM=="net", DRIVERS=="?*", ATTRS{address}=="00:1d:60:0e:a0:a4", 
> NAME="eth1"
> 
> 
> after:
>      # insmod skge.ko
> 
> 
> we have following logs:
> 
> skge 0000:01:05.0: found PCI INT A -> IRQ 10
> skge 1.13 addr 0xfe8ec000 irq 10 chip Yukon-Lite rev 9
> skge eth0: addr 00:1d:60:0e:a0:a4
> 
> 
> so the driver registered "eth0" but later udev changed it to eth1:
> 
>    # cat /proc/interrupts  |grep eth
>      10:          0          0    XT-PIC-XT        uhci_hcd:usb3, eth1
> 
>    # ifconfig  -a
>    eth1      Link encap:Ethernet  HWaddr 00:1D:60:0E:A0:A4
> 	    BROADCAST MULTICAST  MTU:1500  Metric:1
> 	    RX packets:0 errors:0 dropped:0 overruns:0 frame:0
> 	    TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
> 	    collisions:0 txqueuelen:1000
> 	    RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
> 	    Interrupt:10
> 
> 
> So we have "eth1" on interrupt 10, but if we do:
> 
>    # find /proc/irq/ -name 'eth*'
>    /proc/irq/10/eth0
> 
> we still have "eth0" (should be "eth1") connected to interrupt 10.
> 
> 
> The same effect we can achieve with manual changing name of interface 
> (instead of using udev):
> 
>      # ifconfig eth1 down
>      # ip link set eth1 name eth111
>      # ifconfig eth1 up
> 
> 
> 
> For *testing only purposes* I've made some patch which enables 
> interrupts not just after "insmod" but after "ifconfig ethX up" and 
> disables interrupts after "ifconfig ethX down". It is attached to this 
> email.
> 
> With this patch - when we do
> 
>      # ifconfig eth1 down
>      # ip link set eth1 name eth111
>      # ifconfig eth1 up
> 
> it doesn't keep old name of ethX in /proc/irq/*.
> 
> I compared this driver with e1000e-0.5.8.2 for intel e1000e, and
> there after "ifconfig ethX down" they free interrupt handler, and
> "ifconfig ethX up" register it again.


There is one IRQ per device on E1000, and one IRQ per board
that has several devices on skge/sky2.

Your patch doesn't solve the issue when one device is fully up
and another device is added.

> 
> What do you think about this - is it possible to change behaviour of 
> sky2 and skge to the same as in e1000e?
> 
> 
> regards,
> sdrb
> 

It is a generic problem with how devices are renamed and IRQ assignments.
The convention is to use the ethX name in the irq name; this convention
is also assumed/supported by irqbalance. The problem is that there is no
exposed interface to rename the irq!

Probably the simplest workaround would be to make request_irq handle
name overlap.  There is no requirement that /proc/irq exist for proper
functioning of the device.

More labor intensive solution would be to change the convention to not
use the mutable network device name, but instead use something like:
       eth-<drivername>-<counter>
and for multiq drivers
       eth-<drivername>-<counter>-tx-N
That means changing ~200+ drivers.

Another alternative would be to add a rename operation to irq management
and network device notifications to every network device. This preserves
existing naming scheme, but requires changing just as many devices
with added complexity as well.
