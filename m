From: emin ak <eminak71@gmail.com>
Subject: [PROBLEM] linux-2.6.36-rc5 crash with gianfar ethernet at full line
 rate traffic
Date: Sun, 3 Oct 2010 09:20:44 +0300
Message-ID: <AANLkTinxOr3e1CBBFUoFLoC9rwaytkzpsAMCOrmkoHNq@mail.gmail.com>
References: <AANLkTi=Kvi3u5bRp5DtRH-Pr6ALew60cPgeVEZ8V-Dnu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60971 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab0JCGUp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 02:20:45 -0400
Received: by qwh6 with SMTP id 6so2367588qwh.19
        for <netdev@vger.kernel.org>; Sat, 02 Oct 2010 23:20:45 -0700 (PDT)
In-Reply-To: <AANLkTi=Kvi3u5bRp5DtRH-Pr6ALew60cPgeVEZ8V-Dnu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
My problem is kernel crash under full line rate random packet length
ip network traffic.
I'am using default unmodified kernel and default SMP kernel
configuration, MPC8572DS development board and also using a hardware
packet generator.
My test is ip forwarding between eth0 and eth1, and Hardware packet
generator produces full duplex, full line rate traffic with random
packet length and random payload . After a few millions of packets
passed, kernel produces this bellow two different crash messages . I
have retry this scenario many times, crash occurs =A0sometimes on
skb_put, but mostly occurs on ip_rcv function. =A0I have aplied same
test to latest stable linux 2.6.35.6 kernel. Same errors produced.


Any comment and help are appreciated.

Here is crash logs:



Thanks.

Emin


=46irst type of crash:

root@mpc8572ds:~# skb_over_panic: text:c0226280 len:1171 put:1171
head:eed6d000 data:eed63040 tail:0xeed6d4d3 end:0xeed63660 dev:<NULL>
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:127!
Oops: Exception in kernel mode, sig: 5 [#1]
SMP NR_CPUS=3D2 MPC8572 DS
last sysfs file: /sys/devices/pci0002:03/0002:03:00.0/subsystem_device
Modules linked in:
NIP: c023bdcc LR: c023bdcc CTR: c01f3ff8
REGS: effe7d70 TRAP: 0700 =A0 Not tainted =A0(2.6.36-rc5)
MSR: 00029000 <EE,ME,CE> =A0CR: 22028024 =A0XER: 20000000
TASK =3D ef83e9a0[9] 'ksoftirqd/1' THREAD: ef856000 CPU: 1
GPR00: c023bdcc effe7e20 ef83e9a0 0000007c 00021000 ffffffff c01f7b98 c=
03ccf1c
GPR08: c03c69d4 c03f94b4 00c4e000 00000004 20028048 1001a108 ef211000 e=
fb52d90
GPR16: efb52e38 efb52870 00000000 ef211800 00000008 00000009 efb52800 0=
0000037
GPR24: ef24e180 ef2be040 00000000 ef211948 efb52b80 00000493 ef015940 e=
f386600
NIP [c023bdcc] skb_put+0x8c/0x94
LR [c023bdcc] skb_put+0x8c/0x94
Call Trace:
[effe7e20] [c023bdcc] skb_put+0x8c/0x94 (unreliable)
[effe7e30] [c0226280] gfar_clean_rx_ring+0x104/0x4b8
[effe7e90] [c02269dc] gfar_poll+0x3a8/0x60c
[effe7f60] [c024928c] net_rx_action+0xf8/0x1a4
[effe7fa0] [c0042524] __do_softirq+0xe0/0x178
[effe7ff0] [c000e59c] call_do_softirq+0x14/0x24
[ef857f50] [c0004840] do_softirq+0x90/0xa0
[ef857f70] [c00430e4] run_ksoftirqd+0xb4/0x164
[ef857fb0] [c00586b4] kthread+0x7c/0x80
[ef857ff0] [c000e9a8] kernel_thread+0x4c/0x68
Instruction dump:
81030098 2f800000 409e000c 3d20c037 3809a19c 3c60c037 7c8802a6 7d695b78
3863b010 90010008 4cc63182 4be016c5 <0fe00000> 48000000 9421fff0 7c0802=
a6
Kernel panic - not syncing: Fatal exception in interrupt
---------------

second type of crash:

=46aulting instruction address: 0xc026c1dc
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=3D2 MPC8572 DS
last sysfs file: /sys/devices/pci0002:03/0002:03:00.0/subsystem_device
Modules linked in:
NIP: c026c1dc LR: c026bfac CTR: 00000000
REGS: effebd00 TRAP: 0300 =A0 Not tainted =A0(2.6.36-rc5)
MSR: 00029000 <EE,ME,CE> =A0CR: 42028042 =A0XER: 00000000
DEAR: 0000cad8, ESR: 00000000
TASK =3D ef83cde0[3] 'ksoftirqd/0' THREAD: ef84a000 CPU: 0
GPR00: 00000005 effebdb0 ef83cde0 00000000 000001b9 00000000 c1008060 0=
0000000
GPR08: 02c3f605 0000ca00 000005b9 0000ca00 b653a6c7 7af823f0 ef217000 e=
fbab590
GPR16: efbab638 efbab070 00000000 ef217800 00000008 00000018 efbab000 0=
0000028
GPR24: c03f971c c0410000 c0400000 c03f94b4 effea000 ef316e40 00000000 e=
ecb685e
NIP [c026c1dc] ip_rcv+0x3f8/0x808
LR [c026bfac] ip_rcv+0x1c8/0x808
Call Trace:
[effebdb0] [c026c204] ip_rcv+0x420/0x808 (unreliable)
[effebde0] [c02482dc] __netif_receive_skb+0x2f8/0x324
[effebe10] [c02483a4] netif_receive_skb+0x9c/0xb0
[effebe30] [c0226308] gfar_clean_rx_ring+0x18c/0x4b8
[effebe90] [c02269dc] gfar_poll+0x3a8/0x60c
[effebf60] [c024928c] net_rx_action+0xf8/0x1a4
[effebfa0] [c0042524] __do_softirq+0xe0/0x178
[effebff0] [c000e59c] call_do_softirq+0x14/0x24
[ef84bf50] [c0004840] do_softirq+0x90/0xa0
[ef84bf70] [c00430e4] run_ksoftirqd+0xb4/0x164
[ef84bfb0] [c00586b4] kthread+0x7c/0x80
[ef84bff0] [c000e9a8] kernel_thread+0x4c/0x68
Instruction dump:
8148003c 318a0001 7d690194 91680038 9188003c 4bfffd78 7fa3eb78 48002a29
2f830000 40beff50 817d0048 5569003c <a00900d8> 2f800005 419e0034 2f8000=
03
Kernel panic - not syncing: Fatal exception in interrupt
