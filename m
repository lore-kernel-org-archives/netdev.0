From: Marc.Herbert@ens-lyon.fr
Subject: ethtool + tg3 v2.2 + set_pauseparam() = kernel 2.6-t6 segfault
Date: Wed, 8 Oct 2003 16:48:13 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310081613580.3497-100000@bologna>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool + tg3 v2.2 + set_pauseparam() =3D kernel 2.6-t6 segfault

Please find below the log. Complete log (since boot) available on:
http://marc.herbert.free.fr/linux/tg3_set_pauseparam_ethtool_segfault_ker=
n.log

Seems quite reproductible, whatever the ethtool -A options passed.
(you'll forgive me for not trying every combination).

First ethtool invocation segfaults, second call hangs forever. Still
possible to login, even remotely, but most commands hang forever, and
reboot also hangs. tg3 v1.9 (kernel 2.6-t3) was ok. Errr, at least did
not crash, but not sure yet the flow control was working.

2.4 + bcm5700 + flow control works perfectly on same hardware (thanks
to "modprobe bcm5700 tx_flow_control=3DX blabla")

I am not subscribed to the list.


Enjoy.



Oct  7 10:55:08 cluster31 kernel: Linux version 2.6.0-test6 (mherbert@clu=
ster31) (gcc version 2.95.4 20011002 (Debian prerelease)) #1 SMP Mon Oct =
6 17:05:54 CEST 2003


Oct  7 10:56:47 cluster31 kernel: tg3.c:v2.2 (August 24, 2003)
Oct  7 10:56:47 cluster31 kernel: eth1: Tigon3 [partno(none) rev 7100 PHY=
(5401)] (PCI:66MHz:64-bit) 10/100/1000BaseT Ethernet 00:b0:d0:f3:66:4e
Oct  7 10:56:56 cluster31 kernel: tg3: eth1: Link is up at 1000 Mbps, ful=
l duplex.
Oct  7 10:56:56 cluster31 kernel: tg3: eth1: Flow control is off for TX a=
nd off for RX.
Oct  7 10:59:13 cluster31 kernel: tg3: eth1: Link is down.
Oct  7 10:59:16 cluster31 kernel: tg3: eth1: Link is up at 1000 Mbps, ful=
l duplex.
Oct  7 10:59:16 cluster31 kernel: tg3: eth1: Flow control is off for TX a=
nd off for RX.
Oct  7 10:59:38 cluster31 kernel: tg3: eth1: Link is down.
Oct  7 10:59:41 cluster31 kernel: tg3: eth1: Link is up at 1000 Mbps, ful=
l duplex.
Oct  7 10:59:41 cluster31 kernel: tg3: eth1: Flow control is off for TX a=
nd off for RX.
Oct  7 10:59:48 cluster31 kernel: tg3: eth1: Link is down.
Oct  7 10:59:51 cluster31 kernel: tg3: eth1: Link is up at 1000 Mbps, ful=
l duplex.
Oct  7 10:59:51 cluster31 kernel: tg3: eth1: Flow control is off for TX a=
nd off for RX.
Oct  7 11:03:26 cluster31 kernel: tg3: eth1: Link is down.
Oct  7 11:03:39 cluster31 kernel: tg3.c:v2.2 (August 24, 2003)
Oct  7 11:03:40 cluster31 kernel: eth1: Tigon3 [partno(none) rev 7100 PHY=
(5401)] (PCI:66MHz:64-bit) 10/100/1000BaseT Ethernet 00:b0:d0:f3:66:4e
Oct  7 11:36:10 cluster31 kernel: Unable to handle kernel NULL pointer de=
reference at virtual address 00000000
Oct  7 11:36:10 cluster31 kernel:  printing eip:
Oct  7 11:36:10 cluster31 kernel: e08fb55c
Oct  7 11:36:10 cluster31 kernel: *pde =3D 00000000
Oct  7 11:36:10 cluster31 kernel: Oops: 0002 [#1]
Oct  7 11:36:10 cluster31 kernel: CPU:    0
Oct  7 11:36:10 cluster31 kernel: EIP:    0060:[<e08fb55c>]    Not tainte=
d
Oct  7 11:36:10 cluster31 kernel: EFLAGS: 00010046
Oct  7 11:36:10 cluster31 kernel: EIP is at tg3_abort_hw+0x244/0x24c [tg3=
]
Oct  7 11:36:10 cluster31 kernel: eax: 00000000   ebx: 00000000   ecx: 00=
000014   edx: 00000000
Oct  7 11:36:10 cluster31 kernel: esi: de14d200   edi: 00000000   ebp: de=
14d000   esp: dd361e88
Oct  7 11:36:10 cluster31 kernel: ds: 007b   es: 007b   ss: 0068
Oct  7 11:36:10 cluster31 kernel: Process ethtool (pid: 482, threadinfo=3D=
dd360000 task=3Dde3506b0)
Oct  7 11:36:10 cluster31 kernel: Stack: dd360000 00000005 e08fb7ca de14d=
200 de14d200 dd360000 de14d200 00000005
Oct  7 11:36:10 cluster31 kernel:        00000247 e08fe8ad de14d200 00000=
000 de14d000 00000000 dd361ee0 c01b7f1b
Oct  7 11:36:10 cluster31 kernel:        de14d000 dd361ee0 0805a8f0 de14d=
000 dd361f0c 00000000 00000013 00000000
Oct  7 11:36:10 cluster31 kernel: Call Trace:
Oct  7 11:36:10 cluster31 kernel:  [<e08fb7ca>] tg3_halt+0x16/0xc8 [tg3]
Oct  7 11:36:10 cluster31 kernel:  [<e08fe8ad>] tg3_set_pauseparam+0xd5/0=
x16c [tg3]
Oct  7 11:36:10 cluster31 kernel:  [<c01b7f1b>] ethtool_set_pauseparam+0x=
77/0x8c
Oct  7 11:36:10 cluster31 kernel:  [<c01b8a77>] dev_ethtool+0x1df/0x2d8
Oct  7 11:36:10 cluster31 kernel:  [<c01b67b0>] dev_ioctl+0x1a4/0x338
Oct  7 11:36:10 cluster31 kernel:  [<c01f16e8>] inet_ioctl+0xd0/0xdc
Oct  7 11:36:10 cluster31 kernel:  [<c01ae7eb>] sock_ioctl+0x243/0x274
Oct  7 11:36:10 cluster31 kernel:  [<c015b979>] sys_ioctl+0x219/0x260
Oct  7 11:36:10 cluster31 kernel:  [<c010b0bd>] error_code+0x2d/0x38
Oct  7 11:36:10 cluster31 kernel:  [<c010a653>] syscall_call+0x7/0xb
Oct  7 11:36:10 cluster31 kernel:
Oct  7 11:36:10 cluster31 kernel: Code: f3 ab 89 d8 5b 5f c3 90 83 ec 04 =
57 56 53 8b 5c 24 14 8d 7c
Oct  7 11:41:26 cluster31 kernel: Kernel logging (proc) stopped.
Oct  7 11:41:26 cluster31 kernel: Kernel log daemon terminating.
Oct  7 13:43:30 cluster31 kernel: klogd 1.4.1#10, log source =3D /proc/km=
sg started.
Oct  7 13:43:30 cluster31 kernel: Cannot find map file.
Oct  7 13:43:30 cluster31 kernel: No module symbols loaded - kernel modul=
es not enabled.
Oct  7 13:43:30 cluster31 kernel: Linux version 2.6.0-test3 (mherbert@clu=
ster31) (gcc version 2.95.4 20011002 (Debian prerelease)) #1 SMP lun ao=FB=
 18 11:29:59 CEST 2003
Oct  7 13:43:30 cluster31 kernel: Video mode to be used for restore is f0=
0
Oct  7 13:43:30 cluster31 kernel: BIOS-provided physical RAM map:
Oct  7 13:43:30 cluster31 kernel:  BIOS-e820: 0000000000000000 - 00000000=
000a0000 (usable)
