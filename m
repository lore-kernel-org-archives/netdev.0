From: Andy Whitcroft <apw@shadowen.org>
Subject: s390x: getting ipv6 bugs on mainline since 2.6.23-git3
Date: Thu, 18 Oct 2007 10:35:56 +0100
Message-ID: <20071018093556.GT21136@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-s390@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: linux390@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hellhawk.shadowen.org ([80.68.90.175]:2496 "EHLO
	hellhawk.shadowen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872AbXJRJfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:35:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seems we are getting some kind of bug out of our s390x partition (lnxab=
at1)
when booting latest mainline releases, specifically since 2.6.23-git3.

Kernel BUG at 0000000000000002 =DDverbose debug info unavailable=A8
illegal operation: 0001 =DD#1=A8
Modules linked in: dm_mod sit tunnel4 ipv6 qeth ccwgroup qdio dasd_fba_=
mod dasd_
eckd_mod dasd_mod
CPU:    0    Not tainted
Process ip (pid: 2614, task: 000000003f42f680, ksp: 000000003cf2feb8)
Krnl PSW : 0704200180000000 0000000000000002 (0x2)
           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 EA:3
Krnl GPRS: 0000000000000000 0000000000000000 000000003e6d5d00 000000003=
e01f000
           00000000000086dd 000000003cdac144 0000000000000000 000000000=
0000010
           000000003e01f000 000000003d97e3c0 0000000100eaaa00 000000003=
cdac100
           000000003e6d5d00 00000001018fb1d0 0000000000286da8 000000003=
cf2f5e8
Krnl Code:>0000000000000002: 0000               unknown
           0000000000000004: 0000               unknown
           0000000000000006: 0000               unknown
           0000000000000008: 0000               unknown
           000000000000000a: 0000               unknown
           000000000000000c: 0000               unknown
           000000000000000e: 0000               unknown
           0000000000000010: 0000               unknown
Call Trace:
(=DD<0000000000286d60>=A8 neigh_connected_output+0x68/0xfc)
 =DD<00000001018cc7fe>=A8 ip6_output2+0x416/0x4ac =DDipv6=A8
 =DD<00000001018ceaa8>=A8 ip6_output+0xfc4/0xfd4 =DDipv6=A8
 =DD<00000001018dfe40>=A8 __ndisc_send+0x52c/0x6f0 =DDipv6=A8
 =DD<00000001018e0218>=A8 ndisc_send_rs+0x4c/0x5c =DDipv6=A8
 =DD<00000001018d40e6>=A8 addrconf_dad_completed+0xa2/0xf0 =DDipv6=A8
 =DD<00000001018d4880>=A8 addrconf_dad_start+0xa0/0x124 =DDipv6=A8
 =DD<00000001018d496a>=A8 addrconf_add_linklocal+0x66/0x98 =DDipv6=A8
 =DD<00000001018d7a3c>=A8 addrconf_notify+0x6cc/0x898 =DDipv6=A8
 =DD<000000000004ad7c>=A8 notifier_call_chain+0x50/0x8c
 =DD<000000000004b0b6>=A8 __raw_notifier_call_chain+0x1a/0x28
 =DD<000000000004b0e6>=A8 raw_notifier_call_chain+0x22/0x30
 =DD<000000000027f014>=A8 call_netdevice_notifiers+0x28/0x38
 =DD<0000000000281732>=A8 dev_open+0xba/0xd0
 =DD<0000000000281cce>=A8 dev_change_flags+0xbe/0x198
 =DD<00000000002d681c>=A8 devinet_ioctl+0x2c8/0x6c0
 =DD<000000000027138a>=A8 sock_ioctl+0x26e/0x2a0
 =DD<00000000000ab1ce>=A8 do_ioctl+0x4a/0xac
 =DD<00000000000ab5f2>=A8 vfs_ioctl+0x3c2/0x3d8
 =DD<00000000000ab676>=A8 sys_ioctl+0x6e/0x94
 =DD<00000000000215c6>=A8 sysc_noemu+0x10/0x16
 =DD<00000200001201ca>=A8 0x200001201ca

 <0>Kernel panic - not syncing: Fatal exception in interrupt
01: HCPGSP2629I The virtual machine is placed in CP mode due to a SIGP =
stop from
 CPU 00.
02: HCPGSP2629I The virtual machine is placed in CP mode due to a SIGP =
stop from
 CPU 00.
03: HCPGSP2629I The virtual machine is placed in CP mode due to a SIGP =
stop from
 CPU 00.
00: HCPGIR450W CP entered; disabled wait PSW 00020001 80000000 00000000=
 00015FDE

-apw
