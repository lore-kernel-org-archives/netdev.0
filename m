From: Holger Schurig <holgerschurig@gmail.com>
Subject: 4.4.3: OOPS when running "stress-ng --sock 5"
Date: Fri, 04 Mar 2016 08:48:52 +0100
Message-ID: <87twkmd6or.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

on my system I can reproduce reliably a kernel OOPS when I run stress-ng
("apt-get install stress-ng"). Any help on how to track this down would
be appreciated, networking code is outside of my comfort zone (I'm just
a dilettante at device drivers ...).

It takes only a minute or two to get the OOPS:

root@ptxc:~# stress-ng --sock 5
stress-ng: info: [361] dispatching hogs: 0 I/O-Sync, 0 CPU, 0 VM-mmap, 0 HDD-Write, 0 Fork, 0 Context-switch, 0 Pipe, 0 Cache, 5 Socket, 0 Yield, 0 Fallocate, 0 Flock, 0 Affinity, 0 Timer, 0 Dentry, 0 Urandom, 0 Float, 0 Int, 0 Semaphore, 0 Open, 0 SigQueue, 0 Poll
Unable to handle kernel NULL pointer dereference at virtual address 00000104
pgd = ee0d8000
[00000104] *pgd=3e17c831, *pte=00000000, *ppte=00000000
Internal error: Oops: 817 [#1] SMP ARM
Modules linked in: bnep smsc95xx usbnet mii usbhid imx_sdma flexcan btusb btrtl btbcm btintel bluetooth
CPU: 2 PID: 362 Comm: stress-ng-socke Not tainted 4.4.3 #1
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
task: eeb30a00 ti: eea0a000 task.ti: eea0a000
PC is at __rmqueue+0x74/0x308
LR is at 0x3
pc : [<c00972fc>]    lr : [<00000003>]    psr: 60030093
sp : eea0bc08  ip : 00000200  fp : eea0bc54
r10: efd80b14  r9 : 00000008  r8 : 00000000
r7 : 00000003  r6 : 00000000  r5 : c050bff8  r4 : 00000100
r3 : c05ce36c  r2 : 0000006c  r1 : 00000200  r0 : 00000100
Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 10c5387d  Table: 3e0d804a  DAC: 00000051
Process stress-ng-socke (pid: 362, stack limit = 0xeea0a210)
Stack: (0xeea0bc08 to 0xeea0c000)
bc00:                   0000ffff c05ca780 ed93dd80 ed93dd80 eea0bc5c c05ce280
bc20: c03d5838 c03d3b00 c05b04f8 eea0bd5c c050bff8 c050bfe4 c050bfe4 ed93de38
bc40: 00000008 c05ce280 eea0bcec eea0bc58 c0097cb4 c0097294 00000141 0002c26d
bc60: c03d59c4 00000018 c05ced00 c05b0100 ffffacd4 c0439bb0 0000000a c05d19c0
bc80: 00000000 c05b0080 00000100 c05ce490 c05ced08 c05ce3a8 c05cee15 00000128
bca0: 00000141 020252c0 00000000 fffffff8 00000000 eea0bd5c 60030013 00000003
bcc0: eea0bcf4 020052c0 00000003 c05ced00 0000ffcb ed93de38 eea0be84 00000000
bce0: eea0bda4 eea0bcf0 c0098084 c009759c c006caf8 80100010 0fcfc2fc 40030013
bd00: eea0bd24 ed93dd80 ed93dd80 00040000 ed999e00 ed93dd80 eea0bd8c eea0bd28
bd20: c03ee130 c03ebcac 00000002 ef001c00 00000000 024102c0 00000000 000346db
bd40: c05b0100 00000000 00000002 ed93e114 00000005 00000000 00000000 c05ced00
bd60: 00000000 c05ce280 00000000 00000000 00000000 00000000 eea0be84 eeb30eb4
bd80: 024000c0 000005d0 0000ffcb ed93de38 eea0be84 00000000 eea0bdbc eea0bda8
bda0: c0389650 c0097fb8 ed93dd80 ed93dd80 eea0bdd4 eea0bdc0 c03896c8 c03895ec
bdc0: ed999e00 ed93dd80 eea0be4c eea0bdd8 c03e14d4 c03896b8 0000ffcb 00000014
bde0: 000014bf 00000001 eeb30eb4 00000001 00000001 00000000 eea0a018 00000000
be00: eeb30eb4 00000001 0000ffcb 00000560 c0434ca8 0000ffcb 7fffffff 7fffffff
be20: ed958000 ed93dd80 00000000 00000000 00000000 eea6c000 eea0a000 00000000
be40: eea0be6c eea0be50 c0407cbc c03e131c ee98c1a0 ed93dd80 eea0beec 00000000
be60: eea0be7c eea0be70 c0385784 c0407c34 eea0bed4 eea0be80 c0385820 c0385774
be80: c00e6220 00000000 00000000 00000001 00000560 000005d0 eea0bee4 00000001
bea0: 00000000 00000000 00000000 eea0bf00 00000000 eea6c000 eea0bf80 00000000
bec0: 00000000 c000fae4 eea0bf3c eea0bed8 c00c9b2c c03857a0 00000b30 00000004
bee0: eea0bf1c bea359bc 00000b30 00000001 00000000 00000b30 eea0bee4 00000001
bf00: eea6c000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
bf20: eea6c000 00000b30 bea359bc eea0bf80 eea0bf4c eea0bf40 c00c9b84 c00c9ab0
bf40: eea0bf7c eea0bf50 c00ca330 c00c9b5c 00000000 00000000 eea0bf7c eea6c000
bf60: eea6c000 00000b30 bea359bc c000fae4 eea0bfa4 eea0bf80 c00cac0c c00ca2a4
bf80: 00000000 00000000 00000004 0002a1e8 b6f6f140 00000004 00000000 eea0bfa8
bfa0: c000f920 c00cabcc 00000004 0002a1e8 00000004 bea359bc 00000b30 bea379bc
bfc0: 00000004 0002a1e8 b6f6f140 00000004 00000b30 0000016f 0002a1f0 00000003
bfe0: 00000000 bea358f4 00014a57 b6eaa4d6 40030030 00000004 00000000 00000000
Backtrace: 
[<c0097288>] (__rmqueue) from [<c0097cb4>] (get_page_from_freelist+0x724/0x914)
 r10:c05ce280 r9:00000008 r8:ed93de38 r7:c050bfe4 r6:c050bfe4 r5:c050bff8
 r4:eea0bd5c
[<c0097590>] (get_page_from_freelist) from [<c0098084>] (__alloc_pages_nodemask+0xd8/0x898)
 r10:00000000 r9:eea0be84 r8:ed93de38 r7:0000ffcb r6:c05ced00 r5:00000003
 r4:020052c0
[<c0097fac>] (__alloc_pages_nodemask) from [<c0389650>] (skb_page_frag_refill+0x70/0xcc)
 r10:00000000 r9:eea0be84 r8:ed93de38 r7:0000ffcb r6:000005d0 r5:024000c0
 r4:eeb30eb4
[<c03895e0>] (skb_page_frag_refill) from [<c03896c8>] (sk_page_frag_refill+0x1c/0x74)
 r5:ed93dd80 r4:ed93dd80
[<c03896ac>] (sk_page_frag_refill) from [<c03e14d4>] (tcp_sendmsg+0x1c4/0xa58)
 r5:ed93dd80 r4:ed999e00
[<c03e1310>] (tcp_sendmsg) from [<c0407cbc>] (inet_sendmsg+0x94/0xc8)
 r10:00000000 r9:eea0a000 r8:eea6c000 r7:00000000 r6:00000000 r5:00000000
 r4:ed93dd80
[<c0407c28>] (inet_sendmsg) from [<c0385784>] (sock_sendmsg+0x1c/0x2c)
 r5:00000000 r4:eea0beec
[<c0385768>] (sock_sendmsg) from [<c0385820>] (sock_write_iter+0x8c/0xc0)
[<c0385794>] (sock_write_iter) from [<c00c9b2c>] (new_sync_write+0x88/0xac)
 r8:c000fae4 r7:00000000 r6:00000000 r5:eea0bf80 r4:eea6c000
[<c00c9aa4>] (new_sync_write) from [<c00c9b84>] (__vfs_write+0x34/0x40)
 r7:eea0bf80 r6:bea359bc r5:00000b30 r4:eea6c000
[<c00c9b50>] (__vfs_write) from [<c00ca330>] (vfs_write+0x98/0x16c)
[<c00ca298>] (vfs_write) from [<c00cac0c>] (SyS_write+0x4c/0xa8)
 r8:c000fae4 r7:bea359bc r6:00000b30 r5:eea6c000 r4:eea6c000
[<c00cabc0>] (SyS_write) from [<c000f920>] (ret_fast_syscall+0x0/0x3c)
 r7:00000004 r6:b6f6f140 r5:0002a1e8 r4:00000004
Code: e3a04c01 e157000e e1a02102 e3a0cc02 (e5801004) 
---[ end trace 5eaad8c38456d9bc ]---
