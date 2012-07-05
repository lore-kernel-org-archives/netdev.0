From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: ipv6 problem with 6lowpan
Date: Thu, 5 Jul 2012 17:55:24 +0400
Message-ID: <CAJmB2rD8U1ihy4Ai6y5QGjj4f7txDabszesrNrQ=pgEbscePqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35566 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932583Ab2GENz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 09:55:26 -0400
Received: by lbbgm6 with SMTP id gm6so12778776lbb.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 06:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

today I've pulled the latest net-next kernel and tried 802.15.4 stack.
Right after 6lowpan module insertion I got the trace listed in the end
of this mail.
This problem appeared after the latest July merge and reproduces every
time (even without my latest 6lowpan patches).

I haven't yet investigated the details, just want to inform you, may
be some other ipv6 parts are affected too.


Unable to handle kernel NULL pointer dereference at virtual address 00000034
pgd = c3b00000
[00000034] *pgd=23b7e831, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#1] ARM
Modules linked in: 6lowpan
CPU: 0    Not tainted  (3.5.0-rc4+ #23)
PC is at ip6_dst_destroy+0x24/0xd8
LR is at dst_destroy+0x2c/0xf4
pc : [<c028d6a8>]    lr : [<c0222950>]    psr: 20000093
sp : c304bc60  ip : 00000001  fp : 00000000
r10: 00000000  r9 : 00000000  r8 : 00000000
r7 : c39abe60  r6 : 00000000  r5 : c39c6280  r4 : c39abe60
r3 : 20000093  r2 : 20000013  r1 : 00000000  r0 : 00000020
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0005317f  Table: 23b00000  DAC: 00000015
Process ifconfig (pid: 687, stack limit = 0xc304a270)
Stack: (0xc304bc60 to 0xc304c000)
bc60: ffffffff ffffffff 00000000 c0222950 c39abe60 ffffffef c39ab920 00000000
bc80: 00000000 c0291970 c042e1e0 00000000 c39abbc0 c007b590 c304bd7c 00000001
bca0: 00000000 c39abe60 00000020 c304bd14 c398fbe0 c39abe60 c3aa3400 c39c6280
bcc0: c39abed0 00000000 c304bd30 c028f924 00000020 c304bd98 c3aa3400 00000000
bce0: c398fbe0 00000021 c042e1e0 c39aa220 c3aa3400 00000001 00000040 00000005
bd00: c042e1e0 00000000 00000000 c0287a50 00000001 000000fe 00000100 00000040
bd20: 00000000 00000005 00000001 00000002 000080fe 00000000 fecabeba 0000feca
bd40: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
bd60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
bd80: c042e1e0 00000000 c39aa220 c39c6280 c39c6280 00000001 c3aa3400 00000001
bda0: 00000000 c028a544 00000000 c0287104 c3aa3400 c3aa3400 c39c6280 c028bdec
bdc0: c3aa3400 c304be1f c04086e8 c304be1f c304be1f c015b93c c3aa3400 00000014
bde0: 00000000 00000000 00000000 c042e328 ffffffff c042e1e0 00000001 c3aa3400
be00: 00000000 c015ba54 00000000 c3a60860 000080fe 00000000 fecabeba 0000feca
be20: c042e1e0 fffffff8 c04171d0 00000000 00000001 c3aa3400 00000014 00000000
be40: 00000000 c0039028 c3aa3400 00000001 00000000 00000000 c39c658c c00391ac
be60: 00000000 00000001 00000000 c021cd7c c3aa3400 00001002 00000000 c021cddc
be80: bec5bc20 c304a000 00008914 c0264f98 c304a000 bec5bc20 c304bec0 c39c6580
bea0: 00000000 c3aa3400 c3a95e34 c006e750 70776f6c 00306e61 00000000 00000000
bec0: 00001043 00000000 b6f59000 b6d768b0 00001043 00000000 b6f59000 b6d768b0
bee0: 00001002 00008914 bec5bc20 c042e1e0 00000003 c34066e0 c304a000 00000000
bf00: 00000098 c0208114 00005452 bec5bc20 bec5bc20 00000003 c34066e0 c008c4c8
bf20: c304bf60 00000003 00000003 c02eb540 c03f2340 c007eeb8 00000020 c34066c0
bf40: 00000000 00000003 c304bf84 c0208d84 00000000 00000000 c0365008 00000000
bf60: c380e6d0 c34b1a20 c39ff260 bec5bc20 00008914 00000003 c000eaa8 00000000
bf80: 00000098 c008c9b0 00000002 00000000 60000010 0009eb70 bec5be3c bec5bc20
bfa0: 00000036 c000e900 0009eb70 bec5be3c 00000003 00008914 bec5bc20 0009eb70
bfc0: 0009eb70 bec5be3c bec5bc20 00000036 0009eafc 00000000 00000004 00000098
bfe0: bec5bf29 bec5bbf0 0000f4a8 b6e2a0ac 20000010 00000003 00000000 00000000
[<c028d6a8>] (ip6_dst_destroy+0x24/0xd8) from [<c0222950>]
(dst_destroy+0x2c/0xf4)
[<c0222950>] (dst_destroy+0x2c/0xf4) from [<c0291970>] (fib6_add+0x3cc/0x808)
[<c0291970>] (fib6_add+0x3cc/0x808) from [<c028f924>]
(ip6_route_add+0x36c/0x768)
[<c028f924>] (ip6_route_add+0x36c/0x768) from [<c0287a50>]
(addrconf_prefix_route+0x94/0x9c)
[<c0287a50>] (addrconf_prefix_route+0x94/0x9c) from [<c028a544>]
(addrconf_add_linklocal+0x44/0x88)
[<c028a544>] (addrconf_add_linklocal+0x44/0x88) from [<c028bdec>]
(addrconf_notify+0x4e8/0x78c)
[<c028bdec>] (addrconf_notify+0x4e8/0x78c) from [<c0039028>]
(notifier_call_chain+0x44/0x80)
[<c0039028>] (notifier_call_chain+0x44/0x80) from [<c00391ac>]
(raw_notifier_call_chain+0x18/0x20)
[<c00391ac>] (raw_notifier_call_chain+0x18/0x20) from [<c021cd7c>]
(__dev_notify_flags+0x2c/0x5c)
[<c021cd7c>] (__dev_notify_flags+0x2c/0x5c) from [<c021cddc>]
(dev_change_flags+0x30/0x48)
[<c021cddc>] (dev_change_flags+0x30/0x48) from [<c0264f98>]
(devinet_ioctl+0x66c/0x764)
[<c0264f98>] (devinet_ioctl+0x66c/0x764) from [<c0208114>]
(sock_ioctl+0x64/0x25c)
[<c0208114>] (sock_ioctl+0x64/0x25c) from [<c008c4c8>] (do_vfs_ioctl+0x7c/0x52c)
[<c008c4c8>] (do_vfs_ioctl+0x7c/0x52c) from [<c008c9b0>] (sys_ioctl+0x38/0x60)
[<c008c9b0>] (sys_ioctl+0x38/0x60) from [<c000e900>] (ret_fast_syscall+0x0/0x2c)
Code: 0a000008 e10f2000 e3823080 e121f003 (e5903014)
---[ end trace 93e5b562bd1da53e ]---
Kernel panic - not syncing: Fatal exception in interrupt
