From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: BQL support in gianfar causes network hiccup
Date: Mon, 2 Sep 2013 18:35:02 +0300
Message-ID: <5224B026.8090803@freescale.com>
References: <522490CB.60008@appeartv.com> <52249859.2040605@freescale.com> <5224A2A8.6000306@appeartv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Per_Dal=E9n?= <per.dalen@appeartv.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:32615
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757123Ab3IBPfO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 11:35:14 -0400
In-Reply-To: <5224A2A8.6000306@appeartv.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/2013 5:37 PM, Per Dal=E9n wrote:
>> The proposed fix is currently under review:
>> http://patchwork.ozlabs.org/patch/271242/
>> "gianfar: Fix reported number of sent bytes to BQL"
>>
>> Does this one work for you? You might need to pull
>> one recent gianfar clean-up patch from net-next in order
>> to apply this one without incidents.
>>
>
> No, still the same error:
>
> NETDEV WATCHDOG: eth0 (fsl-gianfar): transmit queue 0 timed out
> ------------[ cut here ]------------
> WARNING: at net/sched/sch_generic.c:256
> Modules linked in:
> NIP: c039ce0c LR: c039ce0c CTR: c02ef578
> ...
> 4e800421 80fe0244 4bffff40 7fc3f378 4bfea9d1 7fc4f378 7c651b78 3c60c0=
55
> 7fe6fb78 38635304 4cc63182 480fcddd <0fe00000> 39200001 993c0a3c 4bff=
ffb4
> ---[ end trace 5f5e1e3c30024010 ]---
>
>

Tried to reproduce the issue with a recent net-next kernel (Linux
p2020rdb 3.11.0-rc6) + BQL fix patch (http://patchwork.ozlabs.org/patc
/271242/), but the iperf test finished without incidents (see log
below).
Will try if the problem is apparent without the fix patch, on the same
net-next kernel (3.11.0-rc6).

Claudiu
--
root@p2020rdb:~# ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:04:9f:01:1e:64
           inet addr:192.168.1.100  Bcast:192.168.1.255  Mask:255.255.2=
55.0
           inet6 addr: fe80::204:9fff:fe01:1e64/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1744045 errors:0 dropped:0 overruns:0 frame:0
           TX packets:7242116 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:143012380 (136.3 MiB)  TX bytes:2373808232 (2.2 GiB=
)
           Base address:0x6000

root@p2020rdb:~# ethtool eth2
Settings for eth2:
         Supported ports: [ MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised pause frame use: No
         Advertised auto-negotiation: No
         Speed: 100Mb/s
         Duplex: Half
         Port: MII
         PHYAD: 1
         Transceiver: external
         Auto-negotiation: off
         Supports Wake-on: g
         Wake-on: d
         Current message level: 0x0000003f (63)
                                drv probe link timer ifdown ifup
         Link detected: yes
root@p2020rdb:~# time iperf -c 192.168.1.4 -n 100M -P 50
------------------------------------------------------------
Client connecting to 192.168.1.4, TCP port 5001
TCP window size: 20.7 KByte (default)
------------------------------------------------------------
[ 52] local 192.168.1.100 port 54653 connected with 192.168.1.4 port 50=
01
[  3] local 192.168.1.100 port 54604 connected with 192.168.1.4 port 50=
01
[  4] local 192.168.1.100 port 54605 connected with 192.168.1.4 port 50=
01
[  7] local 192.168.1.100 port 54608 connected with 192.168.1.4 port 50=
01
[  5] local 192.168.1.100 port 54606 connected with 192.168.1.4 port 50=
01
[  8] local 192.168.1.100 port 54609 connected with 192.168.1.4 port 50=
01
[ 10] local 192.168.1.100 port 54610 connected with 192.168.1.4 port 50=
01
[ 11] local 192.168.1.100 port 54611 connected with 192.168.1.4 port 50=
01
[  9] local 192.168.1.100 port 54612 connected with 192.168.1.4 port 50=
01
[ 13] local 192.168.1.100 port 54614 connected with 192.168.1.4 port 50=
01
[ 12] local 192.168.1.100 port 54613 connected with 192.168.1.4 port 50=
01
[ 14] local 192.168.1.100 port 54615 connected with 192.168.1.4 port 50=
01
[ 15] local 192.168.1.100 port 54616 connected with 192.168.1.4 port 50=
01
[ 16] local 192.168.1.100 port 54617 connected with 192.168.1.4 port 50=
01
[ 17] local 192.168.1.100 port 54618 connected with 192.168.1.4 port 50=
01
[ 18] local 192.168.1.100 port 54619 connected with 192.168.1.4 port 50=
01
[ 20] local 192.168.1.100 port 54621 connected with 192.168.1.4 port 50=
01
[ 19] local 192.168.1.100 port 54620 connected with 192.168.1.4 port 50=
01
[  6] local 192.168.1.100 port 54607 connected with 192.168.1.4 port 50=
01
[ 22] local 192.168.1.100 port 54623 connected with 192.168.1.4 port 50=
01
[ 21] local 192.168.1.100 port 54622 connected with 192.168.1.4 port 50=
01
[ 24] local 192.168.1.100 port 54624 connected with 192.168.1.4 port 50=
01
[ 26] local 192.168.1.100 port 54626 connected with 192.168.1.4 port 50=
01
[ 28] local 192.168.1.100 port 54628 connected with 192.168.1.4 port 50=
01
[ 25] local 192.168.1.100 port 54625 connected with 192.168.1.4 port 50=
01
[ 30] local 192.168.1.100 port 54631 connected with 192.168.1.4 port 50=
01
[ 27] local 192.168.1.100 port 54627 connected with 192.168.1.4 port 50=
01
[ 23] local 192.168.1.100 port 54629 connected with 192.168.1.4 port 50=
01
[ 31] local 192.168.1.100 port 54632 connected with 192.168.1.4 port 50=
01
[ 32] local 192.168.1.100 port 54633 connected with 192.168.1.4 port 50=
01
[ 33] local 192.168.1.100 port 54634 connected with 192.168.1.4 port 50=
01
[ 35] local 192.168.1.100 port 54636 connected with 192.168.1.4 port 50=
01
[ 34] local 192.168.1.100 port 54635 connected with 192.168.1.4 port 50=
01
[ 36] local 192.168.1.100 port 54637 connected with 192.168.1.4 port 50=
01
[ 29] local 192.168.1.100 port 54630 connected with 192.168.1.4 port 50=
01
[ 40] local 192.168.1.100 port 54640 connected with 192.168.1.4 port 50=
01
[ 38] local 192.168.1.100 port 54639 connected with 192.168.1.4 port 50=
01
[ 37] local 192.168.1.100 port 54638 connected with 192.168.1.4 port 50=
01
[ 39] local 192.168.1.100 port 54642 connected with 192.168.1.4 port 50=
01
[ 41] local 192.168.1.100 port 54641 connected with 192.168.1.4 port 50=
01
[ 42] local 192.168.1.100 port 54643 connected with 192.168.1.4 port 50=
01
[ 43] local 192.168.1.100 port 54644 connected with 192.168.1.4 port 50=
01
[ 45] local 192.168.1.100 port 54645 connected with 192.168.1.4 port 50=
01
[ 44] local 192.168.1.100 port 54648 connected with 192.168.1.4 port 50=
01
[ 46] local 192.168.1.100 port 54646 connected with 192.168.1.4 port 50=
01
[ 47] local 192.168.1.100 port 54647 connected with 192.168.1.4 port 50=
01
[ 48] local 192.168.1.100 port 54649 connected with 192.168.1.4 port 50=
01
[ 49] local 192.168.1.100 port 54650 connected with 192.168.1.4 port 50=
01
[ 50] local 192.168.1.100 port 54651 connected with 192.168.1.4 port 50=
01
[ 51] local 192.168.1.100 port 54652 connected with 192.168.1.4 port 50=
01
[ ID] Interval       Transfer     Bandwidth
[ 27]  0.0-337.3 sec    100 MBytes  2.49 Mbits/sec
[ 28]  0.0-340.6 sec    100 MBytes  2.46 Mbits/sec
[ 51]  0.0-383.1 sec    100 MBytes  2.19 Mbits/sec
[ 47]  0.0-384.5 sec    100 MBytes  2.18 Mbits/sec
[ 11]  0.0-386.1 sec    100 MBytes  2.17 Mbits/sec
[ 24]  0.0-388.4 sec    100 MBytes  2.16 Mbits/sec
[ 38]  0.0-397.5 sec    100 MBytes  2.11 Mbits/sec
[ 32]  0.0-402.9 sec    100 MBytes  2.08 Mbits/sec
[ 39]  0.0-412.0 sec    100 MBytes  2.04 Mbits/sec
[  6]  0.0-414.5 sec    100 MBytes  2.02 Mbits/sec
[ 50]  0.0-416.3 sec    100 MBytes  2.02 Mbits/sec
[ 31]  0.0-421.3 sec    100 MBytes  1.99 Mbits/sec
[ 25]  0.0-424.8 sec    100 MBytes  1.97 Mbits/sec
[ 17]  0.0-426.4 sec    100 MBytes  1.97 Mbits/sec
[ 52]  0.0-427.7 sec    100 MBytes  1.96 Mbits/sec
[ 20]  0.0-436.2 sec    100 MBytes  1.92 Mbits/sec
[ 29]  0.0-437.5 sec    100 MBytes  1.92 Mbits/sec
[ 33]  0.0-438.6 sec    100 MBytes  1.91 Mbits/sec
[ 37]  0.0-438.6 sec    100 MBytes  1.91 Mbits/sec
[ 40]  0.0-438.7 sec    100 MBytes  1.91 Mbits/sec
[ 14]  0.0-440.1 sec    100 MBytes  1.91 Mbits/sec
[ 15]  0.0-441.5 sec    100 MBytes  1.90 Mbits/sec
[ 22]  0.0-441.7 sec    100 MBytes  1.90 Mbits/sec
[ 35]  0.0-442.7 sec    100 MBytes  1.89 Mbits/sec
[ 48]  0.0-443.2 sec    100 MBytes  1.89 Mbits/sec
[ 26]  0.0-444.8 sec    100 MBytes  1.89 Mbits/sec
[ 16]  0.0-447.0 sec    100 MBytes  1.88 Mbits/sec
[ 49]  0.0-447.6 sec    100 MBytes  1.87 Mbits/sec
[ 12]  0.0-449.5 sec    100 MBytes  1.87 Mbits/sec
[ 10]  0.0-450.3 sec    100 MBytes  1.86 Mbits/sec
[ 46]  0.0-451.0 sec    100 MBytes  1.86 Mbits/sec
[ 18]  0.0-452.9 sec    100 MBytes  1.85 Mbits/sec
[ 19]  0.0-454.2 sec    100 MBytes  1.85 Mbits/sec
[ 30]  0.0-454.5 sec    100 MBytes  1.85 Mbits/sec
[ 21]  0.0-456.2 sec    100 MBytes  1.84 Mbits/sec
[  7]  0.0-456.4 sec    100 MBytes  1.84 Mbits/sec
[ 44]  0.0-456.9 sec    100 MBytes  1.84 Mbits/sec
[ 42]  0.0-458.9 sec    100 MBytes  1.83 Mbits/sec
[ 45]  0.0-458.9 sec    100 MBytes  1.83 Mbits/sec
[  4]  0.0-459.3 sec    100 MBytes  1.83 Mbits/sec
[  3]  0.0-461.5 sec    100 MBytes  1.82 Mbits/sec
[ 36]  0.0-462.2 sec    100 MBytes  1.81 Mbits/sec
[ 13]  0.0-462.7 sec    100 MBytes  1.81 Mbits/sec
[ 34]  0.0-463.0 sec    100 MBytes  1.81 Mbits/sec
[ 43]  0.0-463.1 sec    100 MBytes  1.81 Mbits/sec
[  9]  0.0-463.5 sec    100 MBytes  1.81 Mbits/sec
[  8]  0.0-463.9 sec    100 MBytes  1.81 Mbits/sec
[  5]  0.0-464.2 sec    100 MBytes  1.81 Mbits/sec
[ 41]  0.0-465.1 sec    100 MBytes  1.80 Mbits/sec
[ 23]  0.0-465.3 sec    100 MBytes  1.80 Mbits/sec
[SUM]  0.0-465.3 sec  4.88 GBytes  90.2 Mbits/sec

real    7m45.296s
user    0m0.780s
sys     0m9.636s
