From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: BUG, 3.4.1, l2tp, kernel panic on rmmod =?UTF-8?Q?l=32tp=5Feth?=
Date: Thu, 07 Jun 2012 11:31:56 +0300
Message-ID: <61a2ca9cc47a9a9a1c8a36738090dbf9@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:59229 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504Ab2FGIcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 04:32:05 -0400
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 6FF682EC0AF
	for <netdev@vger.kernel.org>; Thu,  7 Jun 2012 11:31:56 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Sorry for weird looking message, but this is how i got it over 
netconsole

If i have any tunnel+session configured and up and will do rmmod 
l2tp_eth,
i will get panic, after my userspace program will fetch interfaces 
information (over netlink).

Probably it should not rmmod if there is tunnels configured?

[240617.543560] BUG: unable to handle kernel
paging request
at f865b058
[240617.543659] IP:
[<c02db99e>] dev_get_stats+0x13/0x65
[240617.543748] *pdpt = 00000000022d2001
*pde = 0000000035bb8067
*pte = 0000000000000000

[240617.543911] Oops: 0000 [#1]
SMP

[240617.543994] Modules linked in:
netconsole
configfs
nf_conntrack_netlink
nfnetlink
l2tp_netlink
l2tp_ip
l2tp_core
act_skbedit
sch_ingress
sch_sfq
cls_flow
cls_u32
em_meta
cls_basic
xt_dscp
xt_hl
ifb
cls_fw
sch_tbf
sch_htb
act_ipt
act_mirred
ipt_REDIRECT
ipt_REJECT
xt_TCPMSS
ts_bm
xt_connmark
xt_string
xt_DSCP
xt_mark
iptable_mangle
iptable_nat
nf_nat
nf_conntrack_ipv4
nf_conntrack
nf_defrag_ipv4
iptable_filter
8021q
garp
stp
llc
loop
usb_storage
iTCO_wdt
iTCO_vendor_support
ata_piix
pata_acpi
ata_generic
libata
3c59x
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
usb_common
[last unloaded: l2tp_eth]

[240617.544343]
[240617.544343] Pid: 1911, comm: pppvd.temp Tainted: G        W    
3.4.0-build-0061 #12

/DG41CN

[240617.544343] EIP: 0060:[<c02db99e>] EFLAGS: 00210286 CPU: 0
[240617.544343] EIP is at dev_get_stats+0x13/0x65
[240617.544343] EAX: f865b01c EBX: f54dbb60 ECX: 00000000 EDX: f54dbb60
[240617.544343] ESI: c1adc800 EDI: 00000000 EBP: f54dbb38 ESP: f54dbb28
[240617.544343]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[240617.544343] CR0: 8005003b CR2: f865b058 CR3: 35d44000 CR4: 000407f0
[240617.544343] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[240617.544343] DR6: ffff0ff0 DR7: 00000400
[240617.544343] Process pppvd.temp (pid: 1911, ti=f54da000 
task=f5a4e660 task.ti=f54da000)
[240617.544343] Stack:
[240617.544343]  c02364db
f51d48bc
00000000
00000000
f54dbc44
c02e958c
c1adca18
00000010

[240617.544343]  00000002
00000000
f51d4820
f51d47f0
c1adc800
f5542c00
00047df0
00000000

[240617.544343]  0003d80b
00000000
03be13c6
00000000
08ade9a3
00000000
00000000
00000000

[240617.544343] Call Trace:
[240617.544343]  [<c02364db>] ? nla_reserve+0x2b/0x34
[240617.544343]  [<c02e958c>] rtnl_fill_ifinfo+0x3ce/0x77e
[240617.544343]  [<c02ea6b8>] rtnl_dump_ifinfo+0x115/0x1ad
[240617.544343]  [<c02f672c>] netlink_dump+0x57/0x1a8
[240617.544343]  [<c02d6c13>] ? consume_skb+0x2b/0x2e
[240617.544343]  [<c02f69f6>] netlink_recvmsg+0x179/0x248
[240617.544343]  [<c02d005e>] sock_recvmsg+0xb5/0xce
[240617.544343]  [<c01575cb>] ? arch_local_irq_save+0x8/0xb
[240617.544343]  [<c01898e6>] ? might_fault+0x73/0x79
[240617.544343]  [<c02d8400>] ? copy_from_user+0x8/0xa
[240617.544343]  [<c02d8729>] ? verify_iovec+0x3e/0x75
[240617.544343]  [<c02cfd93>] __sys_recvmsg+0xf8/0x17e
[240617.544343]  [<c02cffa9>] ? sock_sendmsg_nosec+0xc2/0xc2
[240617.544343]  [<c01575cb>] ? arch_local_irq_save+0x8/0xb
[240617.544343]  [<c022d4ef>] ? __copy_to_user_ll+0x1c/0x4b
[240617.544343]  [<c022d979>] ? copy_to_user+0x3f/0x46
[240617.544343]  [<c01a63d8>] ? cp_new_stat64+0xe1/0xf3
[240617.544343]  [<c01a42e2>] ? fget_light+0x2b/0x7c
[240617.544343]  [<c02d1646>] sys_recvmsg+0x36/0x4d
[240617.544343]  [<c02d1a8b>] sys_socketcall+0x239/0x27e
[240617.544343]  [<c022d2ec>] ? trace_hardirqs_on_thunk+0xc/0x10
[240617.544343]  [<c034e511>] syscall_call+0x7/0xb
[240617.544343]  [<c0340000>] ? acpi_os_map_memory+0x87/0x13e
[240617.544343] Code:
51
04
89
0a
c7
00
00
01
10
00
c7
40
04
00
02
20
00
f0
80
60
08
fe
5d
c3
55
89
e5
57
56
89
c6
53
89
d3
83
ec
04
8b
80
4c
01
00
00

78
3c
00
89
45
f0
74
15
31
c0
89
d7
b9
2e
00
00
00
f3
ab
89

[240617.544343] EIP: [<c02db99e>]
dev_get_stats+0x13/0x65
SS:ESP 0068:f54dbb28
[240617.544343] CR2: 00000000f865b058
[240617.544343] ---[ end trace ff4846e7d272f02d ]---
[240617.544343] Kernel panic - not syncing: Fatal exception
[240617.544343] Rebooting in 5 seconds..


---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
