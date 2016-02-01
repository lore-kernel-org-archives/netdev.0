From: Holger Schurig <holgerschurig@gmail.com>
Subject: [4.4, OOPS]: kernel oops around __wake_up_common / __sys_recvmsg
Date: Mon, 01 Feb 2016 17:14:09 +0100
Message-ID: <87h9hsl86m.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I (still) have a problem with 4.4.0 having lookups and oopsing. This
happens not instantly: when I run some test program *) on 10 machines, at
the next morning 6-8 have this issue.

Via the serial port I catch the output of "journalctl -f" and get this:

...
06:35:01 CRON[27050]: pam_unix(cron:session): session closed for user root
Unable to handle kernel paging request at virtual address fffffffe
pgd = ee2f4000
[fffffffe] *pgd=3fffd861, *pte=00000000, *ppte=00000000
Internal error: Oops: 80000007 [#1] PREEMPT SMP ARM
Modules linked in: bnep smsc95xx usbnet mii btusb btrtl btbcm btintel bluetooth imx_sdma flexcan dlog(O)
CPU: 3 PID: 331 Comm: Xorg Tainted: G           O    4.4.0 #1
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
task: ee12e3c0 ti: ed996000 task.ti: ed996000
PC is at 0xfffffffe
LR is at __wake_up_common+0x50/0x7c
pc : [<fffffffe>]    lr : [<c0050258>]    psr: 200100b3
sp : ed997c68  ip : ffffffff  fp : ed997c8c
r10: 00000000  r9 : c0037a38  r8 : 00000001
r7 : 00000001  r6 : 00000001  r5 : ee09ad44  r4 : fffffff3
r3 : 00000304  r2 : 00000001  r1 : 00000001  r0 : ee15fd18
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA Thumb  Segment none
Control: 10c5387d  Table: 3e2f404a  DAC: 00000051
Process Xorg (pid: 331, stack limit = 0xed996210)
Stack: (0xed997c68 to 0xed998000)
7c60:                   ee09ad40 a0010013 00000001 00000001 00000304 00000010
7c80: ed997cbc ed997c90 c005084c c0050214 00000304 80150011 c00cfb18 eea1d900
7ca0: eea1d9ac eea1d5e4 ee0d2600 ed997df4 ed997cd4 ed997cc0 c03cd0dc c005080c
7cc0: c03cd05c eea1d900 ed997cec ed997cd8 c0344e08 c03cd068 ee0d2600 ffffffa1
7ce0: ed997d1c ed997cf0 c03cc9b8 c0344dc8 00000010 00000000 00000000 00000000
7d00: 00000000 00000000 c034c4a8 ee0d2600 ed997d34 ed997d20 c0345ed0 c03cc958
7d20: 00000001 ee0d2600 ed997d4c ed997d38 c0346004 c0345e6c 00000001 eea1d400
7d40: ed997d5c ed997d50 c0346174 c0345ffc ed997dec ed997d60 c03cdbc0 c0346128
7d60: ed997d8c ed997d70 c0042bc0 00000010 00000000 00000000 eea1d5bc ecda7b00
7d80: 00000000 eea1d464 00000001 00000000 00000ff0 00000010 00000000 00000000
7da0: 00000000 00000000 00000000 00000000 00000008 c00c06a4 00000008 ed997f54
7dc0: ed997e40 00000040 00001000 ed997f4c ecda7b00 bed92988 ed997e88 ecda7b00
7de0: ed997e2c ed997df0 c03cde00 c03cd60c ed997f54 c03cc7d8 ecda7b00 ed997f4c
7e00: 00000000 00001000 00000040 00000000 ecda7b00 ed997f4c bed9296c 00000040
7e20: ed997e3c ed997e30 c033ea58 c03cddbc ed997f34 ed997e40 c0340774 c033ea4c
7e40: 00000000 00000000 8013c508 00001000 ef7ceb54 ef7cebf8 ed997e94 ed997e68
7e60: c0072fd4 c0014e98 291b24af 0000e16e ed997ebc ef7d43c0 00000000 294a9002
7e80: 0000e16e ef7cebb8 ed997ebc ed997e98 c0074eb8 c0072eac 00000000 ffffffff
7ea0: ffffffff 7fffffff ef7ceb40 ef7cebd8 ed997f14 ed997ec0 c006801c c0074e40
7ec0: ef7cebf8 c0550b40 294a9002 0000e16e 291adbc5 0000e16e 00000003 00000000
7ee0: 294a9002 0000e16e 00000040 00000001 ef005c00 c0563600 ef01ecc0 00000010
7f00: ed997f1c ed997f10 c00d8ae0 ecda7b00 00000000 bed9296c 00000129 c000f2e4
7f20: ed996000 00000000 ed997f94 ed997f38 c03414f8 c03406e8 00000000 7f6d0348
7f40: 00000107 00000000 fffffff7 00000000 00000000 00000000 00000010 00000ff0
7f60: ed997e48 00000001 bed92988 0000020c 00000000 00000000 00000008 bed92988
7f80: 8013b3f0 b6f42f10 ed997fa4 ed997f98 c034152c c03414c0 00000000 ed997fa8
7fa0: c000f120 c0341528 bed92988 8013b3f0 0000000b bed9296c 00000000 cedd7c00
7fc0: bed92988 8013b3f0 b6f42f10 00000129 bed9296c 00001000 8013c508 00000000
7fe0: 00000000 bed92954 7f685a79 b6c2dbd6 60010030 0000000b 3fffd861 3fffdc61
Backtrace:
[<c0050208>] (__wake_up_common) from [<c005084c>] (__wake_up_sync_key+0x4c/0x60)
 r9:00000010 r8:00000304 r7:00000001 r6:00000001 r5:a0010013 r4:ee09ad40
[<c0050800>] (__wake_up_sync_key) from [<c03cd0dc>] (unix_write_space+0x80/0x88)
 r8:ed997df4 r7:ee0d2600 r6:eea1d5e4 r5:eea1d9ac r4:eea1d900
[<c03cd05c>] (unix_write_space) from [<c0344e08>] (sock_wfree+0x4c/0x84)
 r4:eea1d900 r3:c03cd05c
[<c0344dbc>] (sock_wfree) from [<c03cc9b8>] (unix_destruct_scm+0x6c/0x74)
 r5:ffffffa1 r4:ee0d2600
[<c03cc94c>] (unix_destruct_scm) from [<c0345ed0>] (skb_release_head_state+0x70/0xb0)
 r4:ee0d2600
[<c0345e60>] (skb_release_head_state) from [<c0346004>] (__kfree_skb+0x14/0xa8)
 r4:ee0d2600 r3:00000001
[<c0345ff0>] (__kfree_skb) from [<c0346174>] (consume_skb+0x58/0x5c)
 r4:eea1d400 r3:00000001
[<c034611c>] (consume_skb) from [<c03cdbc0>] (unix_stream_read_generic+0x5c0/0x720)
[<c03cd600>] (unix_stream_read_generic) from [<c03cde00>] (unix_stream_recvmsg+0x50/0x5c)
 r10:ecda7b00 r9:ed997e88 r8:bed92988 r7:ecda7b00 r6:ed997f4c r5:00001000
 r4:00000040
[<c03cddb0>] (unix_stream_recvmsg) from [<c033ea58>] (sock_recvmsg+0x18/0x1c)
 r7:00000040 r6:bed9296c r5:ed997f4c r4:ecda7b00
[<c033ea40>] (sock_recvmsg) from [<c0340774>] (___sys_recvmsg+0x98/0x16c)
[<c03406dc>] (___sys_recvmsg) from [<c03414f8>] (__sys_recvmsg+0x44/0x68)
 r10:00000000 r9:ed996000 r8:c000f2e4 r7:00000129 r6:bed9296c r5:00000000
 r4:ecda7b00
[<c03414b4>] (__sys_recvmsg) from [<c034152c>] (SyS_recvmsg+0x10/0x14)
 r6:b6f42f10 r5:8013b3f0 r4:bed92988
[<c034151c>] (SyS_recvmsg) from [<c000f120>] (ret_fast_syscall+0x0/0x3c)
Code: bad PC value
---[ end trace 2c00262b7dd79d60 ]---
note: Xorg[331] exited with preempt_count 1



And here another trace:



...
22:45:01 CRON[7728]: pam_unix(cron:session): session closed for user root
Unable to handle kernel paging request at virtual address fffffffe
pgd = ee230000
[fffffffe] *pgd=3fffd861, *pte=00000000, *ppte=00000000
Internal error: Oops: 80000007 [#1] PREEMPT SMP ARM
Modules linked in: bnep btusb btrtl btbcm btintel bluetooth smsc95xx usbnet mii imx_sdma flexcan dlog(O)
CPU: 3 PID: 331 Comm: Xorg Tainted: G           O    4.4.0 #1
Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
task: ee951f80 ti: ee1a8000 task.ti: ee1a8000
PC is at 0xfffffffe
LR is at __wake_up_common+0x50/0x7c
pc : [<fffffffe>]    lr : [<c0050258>]    psr: 200300b3
sp : ee1a9c68  ip : ffffffff  fp : ee1a9c8c
r10: 00000000  r9 : c0037a38  r8 : 00000001
r7 : 00000001  r6 : 00000001  r5 : e6aa8004  r4 : fffffff3
r3 : 00000304  r2 : 00000001  r1 : 00000001  r0 : eea3fd18
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA Thumb  Segment none
Control: 10c5387d  Table: 3e23004a  DAC: 00000051
Process Xorg (pid: 331, stack limit = 0xee1a8210)
Stack: (0xee1a9c68 to 0xee1aa000)
9c60:                   e6aa8000 a0030013 00000001 00000001 00000304 0000004c
9c80: ee1a9cbc ee1a9c90 c005084c c0050214 00000304 ee1a9b8c c00cfb18 ee93b980
9ca0: ee93ba2c ee93a764 ee1ba6c0 ee1a9df4 ee1a9cd4 ee1a9cc0 c03cd0dc c005080c
9cc0: c03cd05c ee93b980 ee1a9cec ee1a9cd8 c0344e08 c03cd068 ee1ba6c0 ffffffa1
9ce0: ee1a9d1c ee1a9cf0 c03cc9b8 c0344dc8 0000004c 00000000 00000000 00000000
9d00: 00000000 00000000 c034c4a8 ee1ba6c0 ee1a9d34 ee1a9d20 c0345ed0 c03cc958
9d20: 00000001 ee1ba6c0 ee1a9d4c ee1a9d38 c0346004 c0345e6c 00000001 ee93a580
9d40: ee1a9d5c ee1a9d50 c0346174 c0345ffc ee1a9dec ee1a9d60 c03cdbc0 c0346128
9d60: c006c6a8 c0301f64 ee1a9d9c 0000004c 00000000 00000000 ee93a73c ecc51800
9d80: 00000000 ee93a5e4 00000001 00000000 00000fb4 0000004c 00000000 00000000
9da0: 00000000 00000000 00000000 00000000 00000008 c00c06a4 00000008 ee1a9f54
9dc0: ee1a9e40 00000040 00001000 ee1a9f4c ecc51800 be9f9988 ee1a9e88 ecc51800
9de0: ee1a9e2c ee1a9df0 c03cde00 c03cd60c ee1a9f54 c03cc7d8 ecc51800 ee1a9f4c
9e00: 00000000 00001000 00000040 00000000 ecc51800 ee1a9f4c be9f996c 00000040
9e20: ee1a9e3c ee1a9e30 c033ea58 c03cddbc ee1a9f34 ee1a9e40 c0340774 c033ea4c
9e40: 00000000 00000000 80cfa710 00001000 ee1a9e7c ee1a9e60 c0028328 c002778c
9e60: 00000000 ee1a8000 ee951f80 00000504 ee1a9e9c ee1a9e80 c002a3d0 c03e7790
9e80: 00002000 ee1a9ed0 00000000 ee1a9fb0 ee1a9eac ee1a9ea0 c002a3f4 c002a394
9ea0: ee1a9ecc ee1a9eb0 c002a4b4 c002a3e0 00002000 00000000 00000000 be9f95e8
9ec0: ee1a9f8c ee1a9ed0 c00120b0 c002a404 7f69dc39 04000000 b6c22ac1 00002000
9ee0: 00000000 0000000e 00000000 00000080 00000000 00000000 ee1a9f14 ee1a9f08
9f00: ee1a9f1c ee1a9f10 c00d8ae0 ecc51800 00000000 be9f996c 00000129 c000f2e4
9f20: ee1a8000 00000000 ee1a9f94 ee1a9f38 c03414f8 c03406e8 00000000 7f6eb348
9f40: 00000107 00000000 fffffff7 00000000 00000000 00000000 0000004c 00000fb4
9f60: ee1a9e48 00000001 be9f9988 0000020c 00000000 00000000 00000008 be9f9988
9f80: 80cf9d90 b6fa4f10 ee1a9fa4 ee1a9f98 c034152c c03414c0 00000000 ee1a9fa8
9fa0: c000f120 c0341528 be9f9988 80cf9d90 0000000b be9f996c 00000000 2555f400
9fc0: be9f9988 80cf9d90 b6fa4f10 00000129 be9f996c 00001000 80cfa710 00000000
9fe0: 00000000 be9f9954 7f6a0a79 b6c8fbd6 60030030 0000000b 00000000 00000000
Backtrace:
[<c0050208>] (__wake_up_common) from [<c005084c>] (__wake_up_sync_key+0x4c/0x60)
 r9:0000004c r8:00000304 r7:00000001 r6:00000001 r5:a0030013 r4:e6aa8000
[<c0050800>] (__wake_up_sync_key) from [<c03cd0dc>] (unix_write_space+0x80/0x88)
 r8:ee1a9df4 r7:ee1ba6c0 r6:ee93a764 r5:ee93ba2c r4:ee93b980
[<c03cd05c>] (unix_write_space) from [<c0344e08>] (sock_wfree+0x4c/0x84)
 r4:ee93b980 r3:c03cd05c
[<c0344dbc>] (sock_wfree) from [<c03cc9b8>] (unix_destruct_scm+0x6c/0x74)
 r5:ffffffa1 r4:ee1ba6c0
[<c03cc94c>] (unix_destruct_scm) from [<c0345ed0>] (skb_release_head_state+0x70/0xb0)
 r4:ee1ba6c0
[<c0345e60>] (skb_release_head_state) from [<c0346004>] (__kfree_skb+0x14/0xa8)
 r4:ee1ba6c0 r3:00000001
[<c0345ff0>] (__kfree_skb) from [<c0346174>] (consume_skb+0x58/0x5c)
 r4:ee93a580 r3:00000001
[<c034611c>] (consume_skb) from [<c03cdbc0>] (unix_stream_read_generic+0x5c0/0x720)
[<c03cd600>] (unix_stream_read_generic) from [<c03cde00>] (unix_stream_recvmsg+0x50/0x5c)
 r10:ecc51800 r9:ee1a9e88 r8:be9f9988 r7:ecc51800 r6:ee1a9f4c r5:00001000
 r4:00000040
[<c03cddb0>] (unix_stream_recvmsg) from [<c033ea58>] (sock_recvmsg+0x18/0x1c)
 r7:00000040 r6:be9f996c r5:ee1a9f4c r4:ecc51800
[<c033ea40>] (sock_recvmsg) from [<c0340774>] (___sys_recvmsg+0x98/0x16c)
[<c03406dc>] (___sys_recvmsg) from [<c03414f8>] (__sys_recvmsg+0x44/0x68)
 r10:00000000 r9:ee1a8000 r8:c000f2e4 r7:00000129 r6:be9f996c r5:00000000
 r4:ecc51800
[<c03414b4>] (__sys_recvmsg) from [<c034152c>] (SyS_recvmsg+0x10/0x14)
 r6:b6fa4f10 r5:80cf9d90 r4:be9f9988
[<c034151c>] (SyS_recvmsg) from [<c000f120>] (ret_fast_syscall+0x0/0x3c)
Code: bad PC value
---[ end trace 485ed1c9f6b0294a ]---



Here's the disassembly of __wake_up_common, but I can't really see
what's going on:

c0050208 <__wake_up_common>:
c0050208:       e1a0c00d        mov     ip, sp
c005020c:       e92ddbf0        push    {r4, r5, r6, r7, r8, r9, fp, ip, lr, pc}
c0050210:       e24cb004        sub     fp, ip, #4
c0050214:       e1a05000        mov     r5, r0
c0050218:       e1a07001        mov     r7, r1
c005021c:       e5b5c004        ldr     ip, [r5, #4]!
c0050220:       e1a06002        mov     r6, r2
c0050224:       e1a08003        mov     r8, r3
c0050228:       e24c000c        sub     r0, ip, #12
c005022c:       e59c4000        ldr     r4, [ip]
c0050230:       e244400c        sub     r4, r4, #12
c0050234:       e280c00c        add     ip, r0, #12
c0050238:       e15c0005        cmp     ip, r5
c005023c:       0a00000f        beq     c0050280 <__wake_up_common+0x78>
c0050240:       e590c008        ldr     ip, [r0, #8]
c0050244:       e1a01007        mov     r1, r7
c0050248:       e1a02008        mov     r2, r8
c005024c:       e59b3004        ldr     r3, [fp, #4]
c0050250:       e5909000        ldr     r9, [r0]
c0050254:       e12fff3c        blx     ip
c0050258:       e3500000        cmp     r0, #0
c005025c:       0a000003        beq     c0050270 <__wake_up_common+0x68>
c0050260:       e3190001        tst     r9, #1
c0050264:       0a000001        beq     c0050270 <__wake_up_common+0x68>
c0050268:       e2566001        subs    r6, r6, #1
c005026c:       089dabf0        ldmeq   sp, {r4, r5, r6, r7, r8, r9, fp, sp, pc}
c0050270:       e594300c        ldr     r3, [r4, #12]
c0050274:       e1a00004        mov     r0, r4
c0050278:       e243400c        sub     r4, r3, #12
c005027c:       eaffffec        b       c0050234 <__wake_up_common+0x2c>
c0050280:       e89dabf0        ldm     sp, {r4, r5, r6, r7, r8, r9, fp, sp, pc}



The work load is some Java program that sends and receives via Ethernet
(i.MX6 FEC driver), CAN (i.MX6Q flexcan driver) and does some other test
load, e.g. starting and killing user-space threads.
