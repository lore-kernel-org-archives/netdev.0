From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: Fwd: KS8851 SPI Driver Integration
Date: Sat, 21 Nov 2009 18:16:14 -0600
Message-ID: <cb8016980911211616r291b00ddi38a0867e05d947b0@mail.gmail.com>
References: <cb8016980911211610g53a958e8m100238cdcb89cff0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:63805 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753813AbZKVAQK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 19:16:10 -0500
Received: by bwz27 with SMTP id 27so4233622bwz.21
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2009 16:16:15 -0800 (PST)
In-Reply-To: <cb8016980911211610g53a958e8m100238cdcb89cff0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

I am currently working with ks8851snl driver and facing some issues,
the system integrated with is OMAP4, a ARM Cortex A9 Dual Core. I am
using the following commit as latest

commit 94da210af4978b94cb70318bd1b282a73c50b175
Author: Simon Kagstrom <simon.kagstrom@netinsight.net>
=A0 =A0net: fix ks8851 build errors

=A0 =A0Fix build errors due to missing Kconfig select of CRC32:

=A0 =A0ks8851.c:(.text+0x7d2ee): undefined reference to `crc32_le'
=A0 =A0ks8851.c:(.text+0x7d2f5): undefined reference to `bitrev32'

I can summarize the problems as follows:

* Driver won't be able to get ip address via dhcp if SMP/Preemption/L2
Cache are enabled, I have not enabled/disabled one by one to narrow
down the problem...


* Having one single core running, dhcp works, I can ping with small
size packets but cannot mount any nfs directory, 2 different scenarios
listed below, nfs server is up


* Timeout when trying to mount a nfs directory from a system already
booted, if I try to cancel the request then the following messages
will be seen, console access cannot be recovered immediately

=A0rpcbind: server localhost not responding, timed out
=A0CTRL-C
=A0svc: failed to register lockdv1 RPC service (errno 5).
=A0lockd_up: makesock failed, error=3D-5


* Kernel NULL pointer when trying to mount a nfs directory using
bootargs or after some time of pinging to any other ip

Unable to handle kernel NULL pointer dereference at virtual address 000=
00054
pgd =3D c0004000
[00000054] *pgd=3D00000000
Internal error: Oops: 5 [#1]
Modules linked in:
CPU: 0 =A0 =A0Not tainted =A0(2.6.31-00145-g85deb91-dirty #12)
PC is at ks8851_tx_work+0x74/0x19c
LR is at ks8851_tx_work+0x70/0x19c
pc : [<c01b3c04>] =A0 =A0lr : [<c01b3c00>] =A0 =A0psr: a0000013
sp : cf82ff50 =A0ip : cf82ff50 =A0fp : cf82ff8c
r10: cf85e2e1 =A0r9 : cf85e3a0 =A0r8 : cf85e2c8
r7 : cf85e368 =A0r6 : 00000001 =A0r5 : 00000000 =A0r4 : cf85e2c0
r3 : c03316b8 =A0r2 : 00000001 =A0r1 : 00000000 =A0r0 : c02cbd5d
=46lags: NzCv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0ISA ARM =A0Segmen=
t kernel
Control: 10c53c7d =A0Table: 80004059 =A0DAC: 00000017
Process events/0 (pid: 4, stack limit =3D 0xcf82e2e8)
Stack: (0xcf82ff50 to 0xcf830000)
ff40: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 00000000 0000006e cf99f876 00000001
ff60: c0259ac8 c01b3b90 cf800388 cf800380 cf82e000 00000000 00000000 00=
000000
ff80: cf82ffc4 cf82ff90 c004e57c c01b3b9c cf82ffc4 00000000 cf822960 c0=
051e34
ffa0: cf82ffa0 cf82ffa0 cf82ffcc cf825f20 cf800380 c004e474 cf82fff4 cf=
82ffc8
ffc0: c0051a14 c004e480 00000000 00000000 cf82ffd0 cf82ffd0 00000000 00=
000000
ffe0: 00000000 00000000 00000000 cf82fff8 c0041de8 c0051998 ffffffff 00=
000000
Backtrace:
[<c01b3b90>] (ks8851_tx_work+0x0/0x19c) from [<c004e57c>] (worker_threa=
d+0x108/0
x180)
[<c004e474>] (worker_thread+0x0/0x180) from [<c0051a14>] (kthread+0x88/=
0x90)
=A0r7:c004e474 r6:cf800380 r5:cf825f20 r4:cf82ffcc
[<c005198c>] (kthread+0x0/0x90) from [<c0041de8>] (do_exit+0x0/0x580)
=A0r7:00000000 r6:00000000 r5:00000000 r4:00000000
Code: 0a00000d e5940004 ebffd711 e58d5000 (e5952054)
---[ end trace 1c6069e68868725a ]---
ks8851 spi1.0: ks8851_start_xmit: skb cf91c208, 110@cf99f876
ks8851 spi1.0: ks8851_start_xmit: skb cf8e83c0, 110@cf9c8076

I'll appreciate any advice about these issues...

Best Regards
Abraham
