From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: kernel panic in latest vanilla stable, while using nameif with "alive" pppoe interfaces
Date: Mon, 19 Oct 2009 00:02:39 +0300
Message-ID: <200910190002.39937.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:46950 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbZJRVEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 17:04:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have server running as pppoe NAS.
Tried to rename customers without dropping pppd connections first, got panic 
after few seconds.
Panic triggerable at 2.6.30.4 and 2.6.31.4
pppoe users running on eth2
pppoe flags:
 1457 root     /usr/sbin/pppoe-server -I eth2 -k -L 172.16.1.1 -R 
172.16.1.2 -N 253 -C gpzone -S gpzone


Commands sequence that i think triggered that:

ip link set eth0 down
ip link set eth1 down
ip link set eth2 down
nameif etherx 00:16:76:8D:83:BA
nameif eth0 00:19:e0:72:4a:37
nameif eth1 00:19:e0:72:4a:4b

ip addr flush dev eth0
ip addr flush dev eth1
ip addr add X.X.X.X/29 dev eth0
ip addr add 192.168.2.177/24 dev eth0
ip addr add 192.168.0.1/32 dev eth1
ip addr add 127.0.0.0/8 dev lo
#ip link set eth0 up
ip link set eth0 up
ip link set eth1 up
ip link set lo up
ip route add 0.0.0.0/0 via X.X.X.X


[  103.428591] r8169: eth0: link up
[  103.430360] r8169: eth1: link up
[  113.361528] BUG: unable to handle kernel
NULL pointer dereference
at 0000018f
[  113.361717] IP:
[<f8868269>] pppoe_device_event+0x80/0x12c [pppoe]
[  113.361853] *pdpt = 000000003411a001
*pde = 0000000000000000
Oct 18 23:59:40 194.146.153.93
[  113.362012] Oops: 0000 [#1]
SMP
Oct 18 23:59:40 194.146.153.93
[  113.362166] last sysfs file: /sys/devices/virtual/vc/vcs3/dev
[  113.362246] Modules linked in:
netconsole
configfs
act_skbedit
sch_ingress
sch_prio
cls_flow
cls_u32
em_meta
cls_basic
xt_dscp
xt_DSCP
ipt_REJECT
ts_bm
xt_string
xt_hl
ifb
cls_fw
sch_tbf
sch_htb
act_ipt
act_mirred
xt_MARK
pppoe
pppox
ppp_generic
slhc
xt_TCPMSS
xt_mark
xt_tcpudp
iptable_mangle
iptable_nat
nf_nat
rtc_cmos
nf_conntrack_ipv4
rtc_core
nf_conntrack
rtc_lib
nf_defrag_ipv4
iptable_filter
ip_tables
x_tables
8021q
garp
stp
llc
loop
sata_sil
pata_atiixp
pata_acpi
ata_generic
libata
8139cp
usb_storage
mtdblock
mtd_blkdevs
mtd
sr_mod
cdrom
tulip
r8169
sky2
via_velocity
via_rhine
sis900
ne2k_pci
8390
skge
tg3
libphy
8139too
e1000
e100
usbhid
ohci_hcd
uhci_hcd
ehci_hcd
usbcore
nls_base
Oct 18 23:59:40 194.146.153.93
[  113.362344]
[  113.362344] Pid: 2858, comm: pppd Not tainted (2.6.31.4-build-0047 #7)
[  113.362344] EIP: 0060:[<f8868269>] EFLAGS: 00010286 CPU: 0
[  113.362344] EIP is at pppoe_device_event+0x80/0x12c [pppoe]
[  113.362344] EAX: f4fbe000 EBX: ffffffff ECX: f6cea5a0 EDX: f7403680
[  113.362344] ESI: 0000000f EDI: f6cea5e0 EBP: f4145e34 ESP: f4145e1c
[  113.362344]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  113.362344] Process pppd (pid: 2858, ti=f4145000 task=f4112ff0 
task.ti=f4145000)
[  113.362344] Stack:
[  113.362344]  f4fbe220
f4fbe000
f6cea5a0
f886a430
fffffff5
00000000
f4145e54
c01422b3
Oct 18 23:59:40 194.146.153.93
[  113.362344] <0>
f4fbe000
00000009
f8a457d8
f4fbe000
f8850190
00001091
f4145e64
c0142361
Oct 18 23:59:40 194.146.153.93
[  113.362344] <0>
ffffffff
00000000
f4145e74
c029ffbf
f4fbe000
000010d0
f4145e90
c029fa70
Oct 18 23:59:40 194.146.153.93
[  113.362344] Call Trace:
[  113.362344]  [<c01422b3>] ? notifier_call_chain+0x2b/0x4a
[  113.362344]  [<c0142361>] ? raw_notifier_call_chain+0xc/0xe
[  113.362344]  [<c029ffbf>] ? dev_close+0x4c/0x8c
[  113.362344]  [<c029fa70>] ? dev_change_flags+0xa5/0x158
[  113.362344]  [<c02da633>] ? devinet_ioctl+0x21a/0x503
[  113.362344]  [<c02db693>] ? inet_ioctl+0x8d/0xa6
[  113.362344]  [<c0292b21>] ? sock_ioctl+0x1c8/0x1ec
[  113.362344]  [<c0292959>] ? sock_ioctl+0x0/0x1ec
[  113.362344]  [<c019af2b>] ? vfs_ioctl+0x22/0x69
[  113.362344]  [<c019b435>] ? do_vfs_ioctl+0x41f/0x459
[  113.362344]  [<c02934eb>] ? sys_send+0x18/0x1a
[  113.362344]  [<c011942f>] ? do_page_fault+0x242/0x26f
[  113.362344]  [<c019b49b>] ? sys_ioctl+0x2c/0x45
[  113.362344]  [<c0102975>] ? syscall_call+0x7/0xb
[  113.362344] Code:
c9
00
00
00
89
c7
31
f6
83
c7
40
89
f8
e8
cc
60
a9
c7
8b
45
ec
05
20
02
00
00
89
45
e8
8b
4d
f0
8b
1c
b1
e9
8c
00
00
00
8b
45
ec
Oct 18 23:59:40 194.146.153.93
83
90
01
00
00
74
08
8b
9b
8c
01
00
00
eb
79
b8
c0
a6
86
f8
Oct 18 23:59:40 194.146.153.93
[  113.362344] EIP: [<f8868269>]
pppoe_device_event+0x80/0x12c [pppoe]
SS:ESP 0068:f4145e1c
[  113.362344] CR2: 000000000000018f
[  113.373124] ---[ end trace f6fe64a307e97f3b ]---
[  113.373203] Kernel panic - not syncing: Fatal exception in interrupt
[  113.373286] Pid: 2858, comm: pppd Tainted: G      D    2.6.31.4-build-0047 
#7
[  113.373379] Call Trace:
[  113.373479]  [<c02fc496>] ? printk+0xf/0x11
[  113.373561]  [<c02fc3e7>] panic+0x39/0xd9
[  113.373656]  [<c01059b7>] oops_end+0x8b/0x9a
[  113.373727]  [<c0118f6d>] no_context+0x13d/0x147
[  113.373800]  [<c011908a>] __bad_area_nosemaphore+0x113/0x11b
[  113.373881]  [<c02953b3>] ? sock_alloc_send_pskb+0x8b/0x24a
[  113.373959]  [<c0121801>] ? __wake_up_sync_key+0x3b/0x45
[  113.374030]  [<c0131967>] ? irq_exit+0x39/0x5c
[  113.374107]  [<c0104393>] ? do_IRQ+0x80/0x96
[  113.374183]  [<c0102f49>] ? common_interrupt+0x29/0x30
[  113.374259]  [<c011909f>] bad_area_nosemaphore+0xd/0x10
[  113.374348]  [<c0119301>] do_page_fault+0x114/0x26f
[  113.374526]  [<c01191ed>] ? do_page_fault+0x0/0x26f
[  113.374605]  [<c02fe506>] error_code+0x66/0x6c
[  113.374683]  [<c02d007b>] ? tcp_v4_send_ack+0xa3/0x10e
[  113.374764]  [<c01191ed>] ? do_page_fault+0x0/0x26f
[  113.374850]  [<f8868269>] ? pppoe_device_event+0x80/0x12c [pppoe]
[  113.374928]  [<c01422b3>] notifier_call_chain+0x2b/0x4a
[  113.375012]  [<c0142361>] raw_notifier_call_chain+0xc/0xe
[  113.375097]  [<c029ffbf>] dev_close+0x4c/0x8c
[  113.375169]  [<c029fa70>] dev_change_flags+0xa5/0x158
[  113.375239]  [<c02da633>] devinet_ioctl+0x21a/0x503
[  113.375318]  [<c02db693>] inet_ioctl+0x8d/0xa6
[  113.375411]  [<c0292b21>] sock_ioctl+0x1c8/0x1ec
[  113.375491]  [<c0292959>] ? sock_ioctl+0x0/0x1ec
[  113.375574]  [<c019af2b>] vfs_ioctl+0x22/0x69
[  113.375653]  [<c019b435>] do_vfs_ioctl+0x41f/0x459
[  113.375734]  [<c02934eb>] ? sys_send+0x18/0x1a
[  113.375813]  [<c011942f>] ? do_page_fault+0x242/0x26f
[  113.375884]  [<c019b49b>] sys_ioctl+0x2c/0x45
[  113.375960]  [<c0102975>] syscall_call+0x7/0xb
[  113.376041] Rebooting in 5 seconds..
