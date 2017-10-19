From: Sebastien Bourdelin <sebastien.bourdelin@savoirfairelinux.com>
Subject: Kernel 3.0.35 RT - Kernel OOPS error on enet interrupt
Date: Thu, 19 Oct 2017 14:33:02 -0400
Message-ID: <6554df67-5321-833b-4293-47291ad5155b@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
        Ash Charles <ash.charles@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45722 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754318AbdJSSdD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 14:33:03 -0400
Received: from localhost (localhost [127.0.0.1])
        by mail.savoirfairelinux.com (Postfix) with ESMTP id 6014C9C2E95
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 14:33:03 -0400 (EDT)
Content-Language: fr-classic
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm currently stuck with a Kernel OOPS errors which seems to happen when
my system is under heavy load.
The steps to reproduce the problem are unknown from me.

The bug happens when accessing to the __wake_up_common at the following
line:
http://elixir.free-electrons.com/linux/v3.0.35/source/kernel/sched.c#L4456

It seems i'm trying to access a task in a workqueue which has been
poisoning.

I'm wondering if the following calltrace triggers something to you or
what could cause this behavior.

Best Regards,
Sebastien.


Unable to handle kernel paging request at virtual address 00100100
pgd = 80004000
[00100100] *pgd=00000000
Internal error: Oops: 17 [#1] PREEMPT SMP
Modules linked in: sd8xxx mlan(P)
CPU: 3    Tainted: P             (3.0.35-rt56-PD13.2.4-Oct-B421 #1)
PC is at __wake_up_common+0x78/0x90
LR is at try_to_wake_up+0x5c/0x2f4
pc : [<800c5c64>]    lr : [<800cf5f0>]    psr: 60000013
sp : ba2ade18  ip : 001000f4  fp : ba2ade44
r10: 00000001  r9 : 000000c3  r8 : 00000001
r7 : ba457e3c  r6 : 00000000  r5 : 80166620  r4 : 001000f4
r3 : 001000f4  r2 : 00000000  r1 : 20000013  r0 : 00000000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 10c53c7d  Table: 4a5b404a  DAC: 00000015
Process irq/150-enet (pid: 1156, stack limit = 0xba2ac2f0)
Stack: (0xba2ade18 to 0xba2ae000)
de00:                                                       8c0272e0
00000001
de20: 8c0272e0 ba457e20 000000c3 00000001 00000001 00002000 bfd16000
0000004a
de40: ba2ade64 800ce9b0 000000c3 ba809520 ba5d6c00 ba5d6c80 ba5d6c00
ba77c02e
de60: 00000058 8040bf68 ba809520 804e0d8c bfd16000 8072a744 8072a764
ba2adeac
de80: 00000152 bfd16000 00000000 00000000 8072a208 80417980 bfd16000
80418b94
dea0: 8077ea60 ba809520 8c026320 8072a764 807161c0 ba809520 ba2adeec
ffdf53e0
dec0: 00000800 bfd1706c 00000058 bfd1706c 00000800 8041b49c 4a77c810
800ae6b0
dee0: ba77c020 000007f0 00000002 ba2adee4 bfd16000 bfd16000 ffdf53e0
8032b74c
df00: 00000096 00000002 ba809520 8074db9c ba702240 02000000 ffdf53e0
bfd16bcc
df20: 00000000 bfd16c58 4a61a020 bfd1706c bfd17488 bfd17490 80716220
8071620c
df40: 00000000 ba2ac000 ba2ac000 807161c0 807161c0 bfc18220 00000001
bfc18220
df60: 8072a034 80716220 8071620c 8010f850 ba2ac000 807161c0 bfc1823c
8010f768
df80: bffdfe3c 8010f830 bfc18220 00000008 00000013 bffdfe2c bfc18220
8010f620
dfa0: 00000013 00000000 00000000 00000000 00000000 800edf90 00000000
bfc18220
dfc0: 00000000 00000000 00000000 ba2adfcc ba2adfcc 00000000 00000000
00000000
dfe0: ba2adfe0 ba2adfe0 bffdfe2c 800edf10 800a1368 800a1368 a79596d4
c2e48e91
[<800c5c64>] (__wake_up_common+0x78/0x90) from [<800ce9b0>]
(__wake_up_sync_key+0x48/0x64)
[<800ce9b0>] (__wake_up_sync_key+0x48/0x64) from [<8040bf68>]
(sock_def_readable+0x3c/0x64)
[<8040bf68>] (sock_def_readable+0x3c/0x64) from [<804e0d8c>]
(packet_rcv+0x2d8/0x3b8)
[<804e0d8c>] (packet_rcv+0x2d8/0x3b8) from [<80417980>]
(__netif_receive_skb+0x1ac/0x390)
[<80417980>] (__netif_receive_skb+0x1ac/0x390) from [<8041b49c>]
(netif_receive_skb+0xa4/0xb4)
[<8041b49c>] (netif_receive_skb+0xa4/0xb4) from [<8032b74c>]
(fec_enet_interrupt+0x4f8/0x8a0)
[<8032b74c>] (fec_enet_interrupt+0x4f8/0x8a0) from [<8010f850>]
(irq_forced_thread_fn+0x20/0x58)
[<8010f850>] (irq_forced_thread_fn+0x20/0x58) from [<8010f768>]
(irq_thread+0x148/0x1d8)
[<8010f768>] (irq_thread+0x148/0x1d8) from [<800edf90>] (kthread+0x80/0x88)
[<800edf90>] (kthread+0x80/0x88) from [<800a1368>]
(kernel_thread_exit+0x0/0x8)
Code: e51b2028 e2522001 e50b2028 0a000003 (e5b3400c)
