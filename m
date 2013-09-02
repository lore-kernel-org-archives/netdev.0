From: =?ISO-8859-1?Q?Per_Dal=E9n?= <per.dalen@appeartv.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Mon, 02 Sep 2013 18:50:51 +0200
Message-ID: <5224C1EB.3030307@appeartv.com>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com> <5224A2A8.6000306@appeartv.com> <5224B026.8090803@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmx2.itpays.net ([193.107.29.97]:40384 "EHLO
	outmx2.itpays.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122Ab3IBQvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 12:51:02 -0400
Received: from server12.itpays.net (unknown [193.107.28.22])
	by outmx2.itpays.net (Postfix) with SMTP id 62B4C107AAC7
	for <netdev@vger.kernel.org>; Mon,  2 Sep 2013 18:50:59 +0200 (CEST)
In-Reply-To: <5224B026.8090803@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2013 05:35 PM, Claudiu Manoil wrote:
> On 9/2/2013 5:37 PM, Per Dal=E9n wrote:
>>> The proposed fix is currently under review:
>>> http://patchwork.ozlabs.org/patch/271242/
>>> "gianfar: Fix reported number of sent bytes to BQL"
>>>
>>> Does this one work for you? You might need to pull
>>> one recent gianfar clean-up patch from net-next in order
>>> to apply this one without incidents.
>>>
>>
>> No, still the same error:
>>
>> NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit queue 0 timed out
>> ------------[ cut here ]------------
>> WARNING: at net/sched/sch_generic.c:256
>> Modules linked in:
>> NIP: c039ce0c LR: c039ce0c CTR: c02ef578
>> ...
>> 4e800421 80fe0244 4bffff40 7fc3f378 4bfea9d1 7fc4f378 7c651b78 3c60c=
055
>> 7fe6fb78 38635304 4cc63182 480fcddd <0fe00000> 39200001 993c0a3c 4bf=
fffb4
>> ---[ end trace 5f5e1e3c30024010 ]---
>>
>>
>
> Tried to reproduce the issue with a recent net-next kernel (Linux
> p2020rdb 3.11.0-rc6) + BQL fix patch (http://patchwork.ozlabs.org/pat=
c
> /271242/), but the iperf test finished without incidents (see log
> below).
> Will try if the problem is apparent without the fix patch, on the sam=
e
> net-next kernel (3.11.0-rc6).
>

I was able to reproduce it on our card and the P2020RDB using 3.11.0-rc=
7=20
+ David Miller's -next networking tree and your patch=20
(http://patchwork.ozlabs.org/patch/271242/).

root@p2020rdb:~# iperf -s
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3553=
0
[  5] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3553=
1
[  6] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3553=
2
=2E..
[ 51] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3557=
8
[ 52] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3557=
6
[ 53] local 10.10.51.36 port 5001 connected with 10.10.49.116 port 3557=
9

NETDEV WATCHDOG: eth2 (fsl-gianfar): transmit queue 0 timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:264
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.11.0-rc7+ #19
task: ef84f340 ti: ef86a000 task.ti: ef86a000
NIP: c03e9a88 LR: c03e9a88 CTR: c031658c
REGS: ef86bcd0 TRAP: 0700   Not tainted  (3.11.0-rc7+)
MSR: 00029000 <CE,EE,ME>  CR: 22000044  XER: 20000000

GPR00: c03e9a88 ef86bd80 ef84f340 0000003f c0e9e3fc c0e9e9d0 c0316d40=20
00021000
GPR08: 00000007 00000800 00000000 000000ee 000000ee 00000000 00000101=20
00000004
GPR16: 00000001 00200040 ffff00ee c0657040 00000000 ef880e18 ef880c18=20
ffffffff
GPR24: 00000001 ef98c1f4 00000004 efaf31c0 c0650000 c0650000 ef98c000=20
00000000
NIP [c03e9a88] dev_watchdog+0x2d4/0x2e4
LR [c03e9a88] dev_watchdog+0x2d4/0x2e4
Call Trace:
[ef86bd80] [c03e9a88] dev_watchdog+0x2d4/0x2e4 (unreliable)
[ef86bdb0] [c0042cf8] call_timer_fn.isra.25+0x28/0x84
[ef86bdd0] [c0042ee4] run_timer_softirq+0x190/0x208
[ef86be20] [c003b1b8] __do_softirq+0xf4/0x1bc
[ef86be70] [c003b430] irq_exit+0xbc/0xc8
[ef86be80] [c0009490] timer_interrupt+0x1b4/0x1ec
[ef86beb0] [c000ead0] ret_from_except+0x0/0x18
--- Exception: 901 at arch_cpu_idle+0x24/0x5c
     LR =3D arch_cpu_idle+0x24/0x5c
[ef86bf70] [c009bd9c] rcu_idle_enter+0xa4/0xe4 (unreliable)
[ef86bf80] [c007744c] cpu_startup_entry+0xc4/0x15c
[ef86bfb0] [c000fdd8] start_secondary+0x2f0/0x310
[ef86bff0] [c0001ff8] __secondary_start+0x30/0x84
Instruction dump:
4e800421 80fe0208 4bffff40 7fc3f378 4bfe7409 7fc4f378 7c651b78 3c60c05c
7fe6fb78 3863e0b4 4cc63182 4810da7d <0fe00000> 39200001 993c1341 4bffff=
b4
---[ end trace 9e08f5e256de5040 ]---

root@p2020rdb:~# ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:11:22:33:44:aa
           inet addr:10.10.51.36  Bcast:10.10.51.255  Mask:255.255.252.=
0
           inet6 addr: fe80::211:22ff:fe33:44aa/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:336843 errors:0 dropped:0 overruns:0 frame:0
           TX packets:209019 errors:126 dropped:0 overruns:0 carrier:12=
5
           collisions:0 txqueuelen:1000
           RX bytes:505655782 (482.2 MiB)  TX bytes:15060182 (14.3 MiB)
           Base address:0xc000

root@p2020rdb:~# ethtool eth2
Settings for eth2:
         Supported ports: [ MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supported pause frame use: No
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Speed: 100Mb/s
         Duplex: Half
         Port: MII
         PHYAD: 1
         Transceiver: external
         Auto-negotiation: on
         Supports Wake-on: g
         Wake-on: d
         Current message level: 0x0000003f (63)
                                drv probe link timer ifdown ifup
         Link detected: yes
root@p2020rdb:~# dmesg
=2E..
NETDEV WATCHDOG: eth2 (fsl-gianfar): transmit queue 0 timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:264
Modules linked in:
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.11.0-rc7+ #19
task: ef84f340 ti: ef86a000 task.ti: ef86a000
NIP: c03e9a88 LR: c03e9a88 CTR: c031658c
REGS: ef86bcd0 TRAP: 0700   Not tainted  (3.11.0-rc7+)
MSR: 00029000 <CE,EE,ME>  CR: 22000044  XER: 20000000

GPR00: c03e9a88 ef86bd80 ef84f340 0000003f c0e9e3fc c0e9e9d0 c0316d40=20
00021000
GPR08: 00000007 00000800 00000000 000000ee 000000ee 00000000 00000101=20
00000004
GPR16: 00000001 00200040 ffff00ee c0657040 00000000 ef880e18 ef880c18=20
ffffffff
GPR24: 00000001 ef98c1f4 00000004 efaf31c0 c0650000 c0650000 ef98c000=20
00000000
NIP [c03e9a88] dev_watchdog+0x2d4/0x2e4
LR [c03e9a88] dev_watchdog+0x2d4/0x2e4
Call Trace:
[ef86bd80] [c03e9a88] dev_watchdog+0x2d4/0x2e4 (unreliable)
[ef86bdb0] [c0042cf8] call_timer_fn.isra.25+0x28/0x84
[ef86bdd0] [c0042ee4] run_timer_softirq+0x190/0x208
[ef86be20] [c003b1b8] __do_softirq+0xf4/0x1bc
[ef86be70] [c003b430] irq_exit+0xbc/0xc8
[ef86be80] [c0009490] timer_interrupt+0x1b4/0x1ec
[ef86beb0] [c000ead0] ret_from_except+0x0/0x18
--- Exception: 901 at arch_cpu_idle+0x24/0x5c
     LR =3D arch_cpu_idle+0x24/0x5c
[ef86bf70] [c009bd9c] rcu_idle_enter+0xa4/0xe4 (unreliable)
[ef86bf80] [c007744c] cpu_startup_entry+0xc4/0x15c
[ef86bfb0] [c000fdd8] start_secondary+0x2f0/0x310
[ef86bff0] [c0001ff8] __secondary_start+0x30/0x84
Instruction dump:
4e800421 80fe0208 4bffff40 7fc3f378 4bfe7409 7fc4f378 7c651b78 3c60c05c
7fe6fb78 3863e0b4 4cc63182 4810da7d <0fe00000> 39200001 993c1341 4bffff=
b4
---[ end trace 9e08f5e256de5040 ]---


Thanks,
Per

> Claudiu
> --
> root@p2020rdb:~# ifconfig eth2
> eth2      Link encap:Ethernet  HWaddr 00:04:9f:01:1e:64
>            inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255=
=2E255.0
>            inet6 addr: fe80::204:9fff:fe01:1e64/64 Scope:Link
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:1744045 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:7242116 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:1000
>            RX bytes:143012380 (136.3 MiB)  TX bytes:2373808232 (2.2 G=
iB)
>            Base address:0x6000
>
> root@p2020rdb:~# ethtool eth2
> Settings for eth2:
>          Supported ports: [ MII ]
>          Supported link modes:   10baseT/Half 10baseT/Full
>                                  100baseT/Half 100baseT/Full
>                                  1000baseT/Full
>          Supports auto-negotiation: Yes
>          Advertised link modes:  10baseT/Half 10baseT/Full
>                                  100baseT/Half 100baseT/Full
>                                  1000baseT/Full
>          Advertised pause frame use: No
>          Advertised auto-negotiation: No
>          Speed: 100Mb/s
>          Duplex: Half
>          Port: MII
>          PHYAD: 1
>          Transceiver: external
>          Auto-negotiation: off
>          Supports Wake-on: g
>          Wake-on: d
>          Current message level: 0x0000003f (63)
>                                 drv probe link timer ifdown ifup
>          Link detected: yes
> root@p2020rdb:~# time iperf -c 192.168.1.4 -n 100M -P 50
> ------------------------------------------------------------
> Client connecting to 192.168.1.4, TCP port 5001
> TCP window size: 20.7 KByte (default)
> ------------------------------------------------------------
> [ 52] local 192.168.1.100 port 54653 connected with 192.168.1.4 port =
5001
> [  3] local 192.168.1.100 port 54604 connected with 192.168.1.4 port =
5001
> [  4] local 192.168.1.100 port 54605 connected with 192.168.1.4 port =
5001
> [  7] local 192.168.1.100 port 54608 connected with 192.168.1.4 port =
5001
> [  5] local 192.168.1.100 port 54606 connected with 192.168.1.4 port =
5001
> [  8] local 192.168.1.100 port 54609 connected with 192.168.1.4 port =
5001
> [ 10] local 192.168.1.100 port 54610 connected with 192.168.1.4 port =
5001
> [ 11] local 192.168.1.100 port 54611 connected with 192.168.1.4 port =
5001
> [  9] local 192.168.1.100 port 54612 connected with 192.168.1.4 port =
5001
> [ 13] local 192.168.1.100 port 54614 connected with 192.168.1.4 port =
5001
> [ 12] local 192.168.1.100 port 54613 connected with 192.168.1.4 port =
5001
> [ 14] local 192.168.1.100 port 54615 connected with 192.168.1.4 port =
5001
> [ 15] local 192.168.1.100 port 54616 connected with 192.168.1.4 port =
5001
> [ 16] local 192.168.1.100 port 54617 connected with 192.168.1.4 port =
5001
> [ 17] local 192.168.1.100 port 54618 connected with 192.168.1.4 port =
5001
> [ 18] local 192.168.1.100 port 54619 connected with 192.168.1.4 port =
5001
> [ 20] local 192.168.1.100 port 54621 connected with 192.168.1.4 port =
5001
> [ 19] local 192.168.1.100 port 54620 connected with 192.168.1.4 port =
5001
> [  6] local 192.168.1.100 port 54607 connected with 192.168.1.4 port =
5001
> [ 22] local 192.168.1.100 port 54623 connected with 192.168.1.4 port =
5001
> [ 21] local 192.168.1.100 port 54622 connected with 192.168.1.4 port =
5001
> [ 24] local 192.168.1.100 port 54624 connected with 192.168.1.4 port =
5001
> [ 26] local 192.168.1.100 port 54626 connected with 192.168.1.4 port =
5001
> [ 28] local 192.168.1.100 port 54628 connected with 192.168.1.4 port =
5001
> [ 25] local 192.168.1.100 port 54625 connected with 192.168.1.4 port =
5001
> [ 30] local 192.168.1.100 port 54631 connected with 192.168.1.4 port =
5001
> [ 27] local 192.168.1.100 port 54627 connected with 192.168.1.4 port =
5001
> [ 23] local 192.168.1.100 port 54629 connected with 192.168.1.4 port =
5001
> [ 31] local 192.168.1.100 port 54632 connected with 192.168.1.4 port =
5001
> [ 32] local 192.168.1.100 port 54633 connected with 192.168.1.4 port =
5001
> [ 33] local 192.168.1.100 port 54634 connected with 192.168.1.4 port =
5001
> [ 35] local 192.168.1.100 port 54636 connected with 192.168.1.4 port =
5001
> [ 34] local 192.168.1.100 port 54635 connected with 192.168.1.4 port =
5001
> [ 36] local 192.168.1.100 port 54637 connected with 192.168.1.4 port =
5001
> [ 29] local 192.168.1.100 port 54630 connected with 192.168.1.4 port =
5001
> [ 40] local 192.168.1.100 port 54640 connected with 192.168.1.4 port =
5001
> [ 38] local 192.168.1.100 port 54639 connected with 192.168.1.4 port =
5001
> [ 37] local 192.168.1.100 port 54638 connected with 192.168.1.4 port =
5001
> [ 39] local 192.168.1.100 port 54642 connected with 192.168.1.4 port =
5001
> [ 41] local 192.168.1.100 port 54641 connected with 192.168.1.4 port =
5001
> [ 42] local 192.168.1.100 port 54643 connected with 192.168.1.4 port =
5001
> [ 43] local 192.168.1.100 port 54644 connected with 192.168.1.4 port =
5001
> [ 45] local 192.168.1.100 port 54645 connected with 192.168.1.4 port =
5001
> [ 44] local 192.168.1.100 port 54648 connected with 192.168.1.4 port =
5001
> [ 46] local 192.168.1.100 port 54646 connected with 192.168.1.4 port =
5001
> [ 47] local 192.168.1.100 port 54647 connected with 192.168.1.4 port =
5001
> [ 48] local 192.168.1.100 port 54649 connected with 192.168.1.4 port =
5001
> [ 49] local 192.168.1.100 port 54650 connected with 192.168.1.4 port =
5001
> [ 50] local 192.168.1.100 port 54651 connected with 192.168.1.4 port =
5001
> [ 51] local 192.168.1.100 port 54652 connected with 192.168.1.4 port =
5001
> [ ID] Interval       Transfer     Bandwidth
> [ 27]  0.0-337.3 sec    100 MBytes  2.49 Mbits/sec
> [ 28]  0.0-340.6 sec    100 MBytes  2.46 Mbits/sec
> [ 51]  0.0-383.1 sec    100 MBytes  2.19 Mbits/sec
> [ 47]  0.0-384.5 sec    100 MBytes  2.18 Mbits/sec
> [ 11]  0.0-386.1 sec    100 MBytes  2.17 Mbits/sec
> [ 24]  0.0-388.4 sec    100 MBytes  2.16 Mbits/sec
> [ 38]  0.0-397.5 sec    100 MBytes  2.11 Mbits/sec
> [ 32]  0.0-402.9 sec    100 MBytes  2.08 Mbits/sec
> [ 39]  0.0-412.0 sec    100 MBytes  2.04 Mbits/sec
> [  6]  0.0-414.5 sec    100 MBytes  2.02 Mbits/sec
> [ 50]  0.0-416.3 sec    100 MBytes  2.02 Mbits/sec
> [ 31]  0.0-421.3 sec    100 MBytes  1.99 Mbits/sec
> [ 25]  0.0-424.8 sec    100 MBytes  1.97 Mbits/sec
> [ 17]  0.0-426.4 sec    100 MBytes  1.97 Mbits/sec
> [ 52]  0.0-427.7 sec    100 MBytes  1.96 Mbits/sec
> [ 20]  0.0-436.2 sec    100 MBytes  1.92 Mbits/sec
> [ 29]  0.0-437.5 sec    100 MBytes  1.92 Mbits/sec
> [ 33]  0.0-438.6 sec    100 MBytes  1.91 Mbits/sec
> [ 37]  0.0-438.6 sec    100 MBytes  1.91 Mbits/sec
> [ 40]  0.0-438.7 sec    100 MBytes  1.91 Mbits/sec
> [ 14]  0.0-440.1 sec    100 MBytes  1.91 Mbits/sec
> [ 15]  0.0-441.5 sec    100 MBytes  1.90 Mbits/sec
> [ 22]  0.0-441.7 sec    100 MBytes  1.90 Mbits/sec
> [ 35]  0.0-442.7 sec    100 MBytes  1.89 Mbits/sec
> [ 48]  0.0-443.2 sec    100 MBytes  1.89 Mbits/sec
> [ 26]  0.0-444.8 sec    100 MBytes  1.89 Mbits/sec
> [ 16]  0.0-447.0 sec    100 MBytes  1.88 Mbits/sec
> [ 49]  0.0-447.6 sec    100 MBytes  1.87 Mbits/sec
> [ 12]  0.0-449.5 sec    100 MBytes  1.87 Mbits/sec
> [ 10]  0.0-450.3 sec    100 MBytes  1.86 Mbits/sec
> [ 46]  0.0-451.0 sec    100 MBytes  1.86 Mbits/sec
> [ 18]  0.0-452.9 sec    100 MBytes  1.85 Mbits/sec
> [ 19]  0.0-454.2 sec    100 MBytes  1.85 Mbits/sec
> [ 30]  0.0-454.5 sec    100 MBytes  1.85 Mbits/sec
> [ 21]  0.0-456.2 sec    100 MBytes  1.84 Mbits/sec
> [  7]  0.0-456.4 sec    100 MBytes  1.84 Mbits/sec
> [ 44]  0.0-456.9 sec    100 MBytes  1.84 Mbits/sec
> [ 42]  0.0-458.9 sec    100 MBytes  1.83 Mbits/sec
> [ 45]  0.0-458.9 sec    100 MBytes  1.83 Mbits/sec
> [  4]  0.0-459.3 sec    100 MBytes  1.83 Mbits/sec
> [  3]  0.0-461.5 sec    100 MBytes  1.82 Mbits/sec
> [ 36]  0.0-462.2 sec    100 MBytes  1.81 Mbits/sec
> [ 13]  0.0-462.7 sec    100 MBytes  1.81 Mbits/sec
> [ 34]  0.0-463.0 sec    100 MBytes  1.81 Mbits/sec
> [ 43]  0.0-463.1 sec    100 MBytes  1.81 Mbits/sec
> [  9]  0.0-463.5 sec    100 MBytes  1.81 Mbits/sec
> [  8]  0.0-463.9 sec    100 MBytes  1.81 Mbits/sec
> [  5]  0.0-464.2 sec    100 MBytes  1.81 Mbits/sec
> [ 41]  0.0-465.1 sec    100 MBytes  1.80 Mbits/sec
> [ 23]  0.0-465.3 sec    100 MBytes  1.80 Mbits/sec
> [SUM]  0.0-465.3 sec  4.88 GBytes  90.2 Mbits/sec
>
> real    7m45.296s
> user    0m0.780s
> sys     0m9.636s
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
