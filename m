From: "Edy H." <edwardh.dev@gmail.com>
Subject: modprobe gets stuck on a e1000e driver mutex wile trying to load the it
Date: Sun, 6 Mar 2011 14:34:47 +0200
Message-ID: <AANLkTinFPm-7Y_weDqwsF7OxeS-RvzZx1nroz8S7i0bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: e1000-devel@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have an Intel=AE Server Board S5500BC which started to cause problems
during boot, mainly with the e1000e driver, raising the server without
any NIC/s. A reboot ususally recovers the NIC/s.

The following trace is seen from the unit boot, showing an
inconsistent problem while trying to load the e1000e driver.
Looking at the sources, it looks like it is stuck in a critical
section. But I frankly do not understand how it is possible, as there
is no real reason for it to hang on the mutex lock.
At the moment, except memory curroption/leak I cannot think of
anything else... I see it on several machines, so I assume it is not a
specific HW problem.
I will apriciate if someone could point me into some direction.

Note, the pasted message below repeats in a loop, always hangling on
the same lock. In addition, these units also hang from time to time on
initramfs shell, with an avarage of 3 times less frequent than the NIC
issue.
I'm using the following Kernel version:
Linux version 2.6.32-29-generic-pae (buildd@roseapple) (gcc version
4.4.3 (Ubuntu 4.4.3-4ubuntu5) ) #58-Ubuntu SMP Fri Feb 11 19:15:25 UTC
2011 (Ubuntu 2.6.32-29.58-generic-pae 2.6.32.28+drm33.13)

Thanks,
Edy.

This is the relevant trace from the dmesg output:

[=A0=A0=A0 5.732070] lp: driver loaded but no devices found
[=A0=A0=A0 6.002709] Console: switching to colour frame buffer device 8=
0x30
[=A0=A0=A0 6.023688] type=3D1505 audit(1299198224.576:5):
operation=3D"profile_load" pid=3D820 name=3D"/usr/sbin/tcpdump"
[=A0=A0=A0 6.023858] type=3D1505 audit(1299198224.576:6):
operation=3D"profile_replace" pid=3D819 name=3D"/sbin/dhclient3"
[=A0=A0=A0 6.024301] type=3D1505 audit(1299198224.576:7):
operation=3D"profile_replace" pid=3D819
name=3D"/usr/lib/NetworkManager/nm-dhcp-client.action"
[=A0=A0=A0 6.024550] type=3D1505 audit(1299198224.576:8):
operation=3D"profile_replace" pid=3D819
name=3D"/usr/lib/connman/scripts/dhclient-script"
[=A0=A0=A0 6.134782] ip_tables: (C) 2000-2006 Netfilter Core Team
[=A0=A0=A0 6.177099] nf_conntrack version 0.5.0 (16384 buckets, 65536 m=
ax)
[=A0=A0=A0 6.177269] CONFIG_NF_CT_ACCT is deprecated and will be remove=
d
soon. Please use
[=A0=A0=A0 6.177271] nf_conntrack.acct=3D1 kernel parameter, acct=3D1
nf_conntrack module option or
[=A0=A0=A0 6.177273] sysctl net.netfilter.nf_conntrack_acct=3D1 to enab=
le it.
[=A0 240.190031] INFO: task modprobe:178 blocked for more than 120 seco=
nds.
[=A0 240.190534] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[=A0 240.191160] modprobe=A0=A0=A0=A0=A0 D 00183416=A0=A0=A0=A0 0=A0=A0=
 178=A0=A0=A0=A0=A0 1 0x00000000
[=A0 240.191169]=A0 f6e8fd44 00000086 f829b248 00183416 00000000 c088f4=
c0
f6f85be4 c088f4c0
[=A0 240.191186]=A0 6c1f8881 00000000 c088f4c0 c088f4c0 f6f85be4 c088f4=
c0
c088f4c0 f6e3ea00
[=A0 240.191202]=A0 6a3827bd 00000000 f6f85940 f829b238 f829b23c ffffff=
ff
f6e8fd70 c05b3bb6
[=A0 240.191216] Call Trace:
[=A0 240.191231]=A0 [<c05b3bb6>] __mutex_lock_slowpath+0xd6/0x140
[=A0 240.191239]=A0 [<c05b3ac5>] mutex_lock+0x25/0x40
[=A0 240.191255]=A0 [<f8285be1>] e1000_acquire_swflag_ich8lan+0x21/0xa0=
 [e1000e]
[=A0 240.191270]=A0 [<f8286aea>] e1000_reset_hw_ich8lan+0x7a/0x250 [e10=
00e]
[=A0 240.191287]=A0 [<f82940bd>] e1000e_reset+0xfd/0x330 [e1000e]
[=A0 240.191302]=A0 [<f82984e8>] e1000_probe+0x7b7/0xa09 [e1000e]
[=A0 240.191309]=A0 [<c0227745>] ? iput+0x25/0x60
[=A0 240.191316]=A0 [<c026af3b>] ? sysfs_addrm_finish+0x3b/0xf0
[=A0 240.191325]=A0 [<c0370043>] local_pci_probe+0x13/0x20
[=A0 240.191331]=A0 [<c0370e48>] pci_device_probe+0x68/0x90
[=A0 240.191339]=A0 [<c03fceed>] really_probe+0x4d/0x140
[=A0 240.191347]=A0 [<c040380e>] ? pm_runtime_barrier+0x4e/0xc0
[=A0 240.191354]=A0 [<c03fd01c>] driver_probe_device+0x3c/0x60
[=A0 240.191361]=A0 [<c03fd0c1>] __driver_attach+0x81/0x90
[=A0 240.191368]=A0 [<c03fc503>] bus_for_each_dev+0x53/0x80
[=A0 240.191375]=A0 [<c03fcdbe>] driver_attach+0x1e/0x20
[=A0 240.191382]=A0 [<c03fd040>] ? __driver_attach+0x0/0x90
[=A0 240.191389]=A0 [<c03fc785>] bus_add_driver+0xd5/0x280
[=A0 240.191396]=A0 [<c0370d80>] ? pci_device_remove+0x0/0x40
[=A0 240.191403]=A0 [<c03fd3ba>] driver_register+0x6a/0x130
[=A0 240.191410]=A0 [<c0371085>] __pci_register_driver+0x45/0xb0
[=A0 240.191423]=A0 [<f82a304b>] e1000_init_module+0x4b/0x67 [e1000e]
[=A0 240.191430]=A0 [<c0103041>] do_one_initcall+0x31/0x190
[=A0 240.191443]=A0 [<f82a3000>] ? e1000_init_module+0x0/0x67 [e1000e]
[=A0 240.191452]=A0 [<c018acb0>] sys_init_module+0xb0/0x210
[=A0 240.191458]=A0 [<c01097ac>] syscall_call+0x7/0xb


lshw network output:

=A0 *-network
=A0=A0=A0=A0=A0=A0 description: Ethernet interface
=A0=A0=A0=A0=A0=A0 product: 82574L Gigabit Network Connection
=A0=A0=A0=A0=A0=A0 vendor: Intel Corporation
=A0=A0=A0=A0=A0=A0 physical id: 0
=A0=A0=A0=A0=A0=A0 bus info: pci@0000:01:00.0
=A0=A0=A0=A0=A0=A0 logical name: eth1
=A0=A0=A0=A0=A0=A0 version: 00
=A0=A0=A0=A0=A0=A0 serial: 00:1b:21:57:0a:54
=A0=A0=A0=A0=A0=A0 size: 100MB/s
=A0=A0=A0=A0=A0=A0 capacity: 1GB/s
=A0=A0=A0=A0=A0=A0 width: 32 bits
=A0=A0=A0=A0=A0=A0 clock: 33MHz
=A0=A0=A0=A0=A0=A0 capabilities: pm msi pciexpress msix bus_master cap_=
list rom
ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd
autonegotiation
=A0=A0=A0=A0=A0=A0 configuration: autonegotiation=3Doff broadcast=3Dyes=
 driver=3De1000e
driverversion=3D1.0.2-k2 duplex=3Dfull firmware=3D1.8-0 ip=3D127.0.1.1
latency=3D0 link=3Dyes multicast=3Dyes port=3Dtwisted pair speed=3D100M=
B/s
=A0=A0=A0=A0=A0=A0 resources: irq:16 memory:b1a80000-b1a9ffff
memory:b1a00000-b1a7ffff ioport:2000(size=3D32) memory:b1aa0000-b1aa3ff=
f
memory:b1c00000-b1c3ffff(prefetchable)
=A0 *-network
=A0=A0=A0=A0=A0=A0 description: Ethernet interface
=A0=A0=A0=A0=A0=A0 product: 82578DM Gigabit Network Connection
=A0=A0=A0=A0=A0=A0 vendor: Intel Corporation
=A0=A0=A0=A0=A0=A0 physical id: 19
=A0=A0=A0=A0=A0=A0 bus info: pci@0000:00:19.0
=A0=A0=A0=A0=A0=A0 logical name: eth0
=A0=A0=A0=A0=A0=A0 version: 05
=A0=A0=A0=A0=A0=A0 serial: 00:15:17:c8:0a:3d
=A0=A0=A0=A0=A0=A0 size: 100MB/s
=A0=A0=A0=A0=A0=A0 capacity: 1GB/s
=A0=A0=A0=A0=A0=A0 width: 32 bits
=A0=A0=A0=A0=A0=A0 clock: 33MHz
=A0=A0=A0=A0=A0=A0 capabilities: pm msi bus_master cap_list ethernet ph=
ysical tp
10bt 10bt-fd 100bt 100bt-fd 1000bt-fd autonegotiation
=A0=A0=A0=A0=A0=A0 configuration: autonegotiation=3Doff broadcast=3Dyes=
 driver=3De1000e
driverversion=3D1.0.2-k2 duplex=3Dfull firmware=3D0.9-2 ip=3D127.0.0.1
latency=3D0 link=3Dyes multicast=3Dyes port=3Dtwisted pair speed=3D100M=
B/s
=A0=A0=A0=A0=A0=A0 resources: irq:34 memory:b1b00000-b1b1ffff
memory:b1b24000-b1b24fff ioport:3020(size=3D32)
=A0 *-network
=A0=A0=A0=A0=A0=A0 description: Ethernet interface
=A0=A0=A0=A0=A0=A0 product: 82574L Gigabit Network Connection
=A0=A0=A0=A0=A0=A0 vendor: Intel Corporation
=A0=A0=A0=A0=A0=A0 physical id: 0
=A0=A0=A0=A0=A0=A0 bus info: pci@0000:03:00.0
=A0=A0=A0=A0=A0=A0 logical name: eth2
=A0=A0=A0=A0=A0=A0 version: 00
=A0=A0=A0=A0=A0=A0 serial: 00:15:17:c8:0a:3c
=A0=A0=A0=A0=A0=A0 size: 100MB/s
=A0=A0=A0=A0=A0=A0 capacity: 1GB/s
=A0=A0=A0=A0=A0=A0 width: 32 bits
=A0=A0=A0=A0=A0=A0 clock: 33MHz
=A0=A0=A0=A0=A0=A0 capabilities: pm msi pciexpress msix bus_master cap_=
list
ethernet physical tp 10bt 10bt-fd 100bt 100bt-fd 1000bt-fd
autonegotiation
=A0=A0=A0=A0=A0=A0 configuration: autonegotiation=3Don broadcast=3Dyes =
driver=3De1000e
driverversion=3D1.0.2-k2 duplex=3Dfull firmware=3D1.9-0 ip=3D172.17.6.2
latency=3D0 link=3Dyes multicast=3Dyes port=3Dtwisted pair speed=3D100M=
B/s
=A0=A0=A0=A0=A0=A0 resources: irq:16 memory:b1900000-b191ffff ioport:10=
00(size=3D32)
memory:b1920000-b1923fff
=A0 *-network:0 DISABLED
=A0=A0=A0=A0=A0=A0 description: Ethernet interface
=A0=A0=A0=A0=A0=A0 physical id: 1
=A0=A0=A0=A0=A0=A0 logical name: eth1.24
=A0=A0=A0=A0=A0=A0 serial: 00:1b:21:57:0a:54
=A0=A0=A0=A0=A0=A0 size: 100MB/s
=A0=A0=A0=A0=A0=A0 capacity: 1GB/s
=A0=A0=A0=A0=A0=A0 capabilities: ethernet physical tp 10bt 10bt-fd 100b=
t 100bt-fd
1000bt-fd autonegotiation
=A0=A0=A0=A0=A0=A0 configuration: autonegotiation=3Doff broadcast=3Dyes=
 driver=3D802.1Q
VLAN Support driverversion=3D1.8 duplex=3Dfull firmware=3DN/A link=3Dye=
s
multicast=3Dyes port=3Dtwisted pair speed=3D100MB/s
=A0 *-network:1
=A0=A0=A0=A0=A0=A0 description: Ethernet interface
=A0=A0=A0=A0=A0=A0 physical id: 2
=A0=A0=A0=A0=A0=A0 logical name: vlan24
=A0=A0=A0=A0=A0=A0 serial: 00:15:17:c8:0a:3d
=A0=A0=A0=A0=A0=A0 size: 100MB/s
=A0=A0=A0=A0=A0=A0 capacity: 1GB/s
=A0=A0=A0=A0=A0=A0 capabilities: ethernet physical tp 10bt 10bt-fd 100b=
t 100bt-fd
1000bt-fd autonegotiation
=A0=A0=A0=A0=A0=A0 configuration: autonegotiation=3Doff broadcast=3Dyes=
 driver=3D802.1Q
VLAN Support driverversion=3D1.8 duplex=3Dfull firmware=3DN/A
ip=3D172.24.4.182 link=3Dyes multicast=3Dyes port=3Dtwisted pair speed=3D=
100MB/s
