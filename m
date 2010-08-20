From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 09:57:22 +0300
Message-ID: <4C6E2752.6020405@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	 <20100819152143.8a57c465.akpm@linux-foundation.org>	 <4C6E0C99.2060407@fs.uni-ruse.bg>	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>	 <4C6E1CBA.2060605@fs.uni-ruse.bg>	 <20100819232019.6f6074a8.akpm@linux-foundation.org>	 <4C6E202E.5030406@fs.uni-ruse.bg> <1282286070.2295.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:53651 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751494Ab0HTG5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 02:57:25 -0400
In-Reply-To: <1282286070.2295.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 09:34, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Le vendredi 20 ao=C3=BBt 2010 =C3=A0 09:26 +0300, Plamen Petrov a =C3=
=A9crit :
>> Posting this only in the hope that it will be helpfull to the
>> "net guys"...
>
> Its a forwarding setup.
>
> Please post
>
> ifconfig -a
> iptables -nvL
> iptables -t nat -nvL
> iptables -t mangle -nvL
> ip route
> ethtool -k eth0   (&  eth1 ...)
>
> Try to disable gro ?
> ethtool -K eth0 gro off
> ethtool -K eth1 gro off
>
>
Here goes the output of the above:
root@fs:~# ifconfig -a
> eth0      Link encap:Ethernet  HWaddr 00:0E:2E:5C:27:EF
>           inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.25=
5.0
>           inet6 addr: fe80::20e:2eff:fe5c:27ef/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:40986 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:32825 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:36081064 (34.4 MiB)  TX bytes:6457150 (6.1 MiB)
>           Interrupt:18 Base address:0xe00
>
> eth1      Link encap:Ethernet  HWaddr 00:1A:A0:38:8A:1B
>           inet addr:192.168.10.1  Bcast:192.168.10.255  Mask:255.255.=
255.0
>           inet6 addr: fe80::21a:a0ff:fe38:8a1b/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:1220443 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:568452 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1477959893 (1.3 GiB)  TX bytes:144840881 (138.1 Mi=
B)
>           Interrupt:17
>
> eth2      Link encap:Ethernet  HWaddr 00:0E:2E:5C:27:E6
>           inet addr:192.168.199.1  Bcast:192.168.199.255  Mask:255.25=
5.255.0
>           inet6 addr: fe80::20e:2eff:fe5c:27e6/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:1119 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:1149 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:210401 (205.4 KiB)  TX bytes:505063 (493.2 KiB)
>           Interrupt:16 Base address:0x4f00
>
> gre0      Link encap:UNSPEC  HWaddr 00-00-00-00-FF-00-73-69-00-00-00-=
00-00-00-00-00
>           NOARP  MTU:1476  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> ifb0      Link encap:Ethernet  HWaddr 96:9F:C4:43:78:01
>           BROADCAST NOARP  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:32
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> ifb1      Link encap:Ethernet  HWaddr EA:B9:BD:02:C1:77
>           BROADCAST NOARP  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:32
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> ip6tnl0   Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-=
00-00-00-00-00
>           NOARP  MTU:1460  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           inet6 addr: ::1/128 Scope:Host
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:13546 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:13546 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:1051287 (1.0 MiB)  TX bytes:1051287 (1.0 MiB)
>
> sit0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-73-69-00-00-00-=
00-00-00-00-00
>           NOARP  MTU:1480  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> sixxs_t   Link encap:UNSPEC  HWaddr C0-A8-01-02-00-00-73-69-00-00-00-=
00-00-00-00-00
>           inet6 addr: 2001:15c0:65ff:64::2/64 Scope:Global
>           inet6 addr: fe80::c0a8:102/128 Scope:Link
>           UP POINTOPOINT RUNNING NOARP  MTU:1280  Metric:1
>           RX packets:145 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:145 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:15080 (14.7 KiB)  TX bytes:15080 (14.7 KiB)
>
> teql0     Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-=
00-00-00-00-00
>           NOARP  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:100
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> tun0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-=
00-00-00-00-00
>           inet addr:192.168.11.1  P-t-P:192.168.11.2  Mask:255.255.25=
5.255
>           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:100
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
> tunl0     Link encap:IPIP Tunnel  HWaddr
>           NOARP  MTU:1480  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>
root@fs:~# iptables -nvL
> Chain INPUT (policy ACCEPT 1207K packets, 1455M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:53
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:53
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:135
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:137
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:138
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:139
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:445
>     0     0 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:993
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:135
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:137
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:138
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:139
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:445
>     0     0 DROP       udp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           udp dpt:993
>
> Chain FORWARD (policy DROP 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>     0     0 ACCEPT     all  --  tun0   *       0.0.0.0/0            0=
=2E0.0.0/0
>     0     0 ACCEPT     all  --  *      tun0    0.0.0.0/0            0=
=2E0.0.0/0
>     0     0 ACCEPT     all  --  eth2   eth1    192.168.199.15       1=
92.168.10.0/24
>     0     0 REJECT     all  --  eth2   *       0.0.0.0/0            1=
92.168.1.1         reject-with icmp-net-unreachable
>     0     0 REJECT     all  --  eth1   *       0.0.0.0/0            1=
92.168.1.1         reject-with icmp-net-unreachable
> 29650 5450K ACCEPT     all  --  eth1   eth0    192.168.10.0/24     !1=
92.168.1.1
>   821  165K ACCEPT     all  --  eth2   eth0    192.168.199.0/24    !1=
92.168.1.1
>     0     0 ACCEPT     all  --  eth2   eth1    192.168.199.0/24     1=
92.168.10.5
>   624  438K ACCEPT     tcp  --  *      eth2    0.0.0.0/0            1=
92.168.199.0/24    tcp flags:!0x17/0x02
> 33228   34M ACCEPT     tcp  --  *      eth1    0.0.0.0/0            1=
92.168.10.0/24     tcp flags:!0x17/0x02
>   199 14395 ACCEPT    !tcp  --  *      eth2    0.0.0.0/0            1=
92.168.199.0/24
>  2891  597K ACCEPT    !tcp  --  *      eth1    0.0.0.0/0            1=
92.168.10.0/24
>
> Chain OUTPUT (policy ACCEPT 546K packets, 100M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
root@fs:~# iptables -t nat -nvL
> Chain PREROUTING (policy DROP 701 packets, 94310 bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>     0     0 LOG        tcp  --  eth1   *       192.168.10.0/24     !1=
92.168.10.1        tcp dpt:25 LOG flags 0 level 4
>     0     0 DROP       tcp  --  eth1   *       192.168.10.0/24     !1=
92.168.10.1        tcp dpt:25
>     0     0 LOG        tcp  --  eth2   *       192.168.199.0/24    !1=
92.168.199.1       tcp dpt:25 LOG flags 0 level 4
>     0     0 DROP       tcp  --  eth2   *       192.168.199.0/24    !1=
92.168.199.1       tcp dpt:25
>     0     0 LOG        tcp  --  tun0   *       192.168.11.0/24     !1=
92.168.11.1        tcp dpt:25 LOG flags 0 level 4
>     0     0 DROP       tcp  --  tun0   *       192.168.11.0/24     !1=
92.168.11.1        tcp dpt:25
>     0     0 ACCEPT     all  --  tun0   *       0.0.0.0/0            0=
=2E0.0.0/0
>     0     0 ACCEPT     all  --  *      *       0.0.0.0/0            1=
92.168.11.0/24
>     0     0 ACCEPT     all  --  *      *       192.168.11.0/24      0=
=2E0.0.0/0
>     0     0 DROP       tcp  --  *      *       87.249.45.135        0=
=2E0.0.0/0           tcp dpts:20:22
>     0     0 ACCEPT     all  --  eth0   *       212.18.63.73         1=
92.168.1.2
>     0     0 ACCEPT     all  --  eth2   *       192.168.199.15       1=
92.168.10.0/24
>     0     0 DROP       all  --  eth2   *       192.168.199.0/24     1=
92.168.10.0/24
>     0     0 DROP       all  --  eth1   *       192.168.10.0/24      1=
92.168.199.0/24
>  5629  597K ACCEPT     all  --  eth1   *       192.168.10.0/24      0=
=2E0.0.0/0
>   262 26231 ACCEPT     all  --  eth2   *       192.168.199.0/24     0=
=2E0.0.0/0
>     0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:21 state NEW,ESTABLISHED
>     0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp spts:1024:65535 dpts:1024:65535 state RELATED,ES=
TABLISHED
>     0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpts:20:21 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       77.0.0.0/8           1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       87.0.0.0/8           1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       90.0.0.0/8           1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       95.0.0.0/8           1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       212.45.77.11         1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>     0     0 LOG        tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02 LOG flags 0 level 4
>     0     0 DROP       tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:22 flags:0x17/0x02
>    11   628 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:25 flags:0x17/0x02
>     2    96 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:80 flags:0x17/0x02
>     2   100 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:443 flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            1=
92.168.1.2         tcp dpt:41414 flags:0x17/0x02
>  1197 58544 DROP       tcp  --  eth0   *       0.0.0.0/0            0=
=2E0.0.0/0           tcp flags:0x17/0x02
>     0     0 ACCEPT     tcp  --  eth0   *       0.0.0.0/0            1=
92.168.1.2         tcp dpts:1023:65500
>     6  2006 ACCEPT     udp  --  eth1   *       0.0.0.0              2=
55.255.255.255     udp spts:67:68 dpts:67:68
>     1   328 ACCEPT     udp  --  eth2   *       0.0.0.0              2=
55.255.255.255     udp spts:67:68 dpts:67:68
>
> Chain OUTPUT (policy ACCEPT 2685 packets, 196K bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>
> Chain POSTROUTING (policy ACCEPT 2656 packets, 186K bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>     1   124 ACCEPT     all  --  *      eth0    192.168.1.2          2=
12.18.63.73
>     0     0 ACCEPT     tcp  --  *      eth0    192.168.1.2          0=
=2E0.0.0/0           tcp spts:1024:65535 dpts:1024:65535 state RELATED,=
ESTABLISHED
>     0     0 ACCEPT     tcp  --  *      eth0    192.168.1.2          0=
=2E0.0.0/0           tcp spt:20 state RELATED,ESTABLISHED
>     0     0 SNAT       all  --  *      eth0    192.168.10.16/29     0=
=2E0.0.0/0           to:192.168.1.2
>     4   192 SNAT       all  --  *      eth0    192.168.10.24/29     0=
=2E0.0.0/0           to:192.168.1.2
>     0     0 SNAT       all  --  *      eth0    192.168.10.32/29     0=
=2E0.0.0/0           to:192.168.1.2
>     0     0 SNAT       all  --  *      eth0    192.168.10.40/29     0=
=2E0.0.0/0           to:192.168.1.2
>     0     0 SNAT       all  --  *      eth0    192.168.10.48/29     0=
=2E0.0.0/0           to:192.168.1.2
>     0     0 SNAT       all  --  *      eth0    192.168.10.56/29     0=
=2E0.0.0/0           to:192.168.1.2
>     0     0 SNAT       all  --  *      eth0    192.168.10.64/28     0=
=2E0.0.0/0           to:192.168.1.2
>  4893  516K SNAT       all  --  *      eth0    192.168.10.0/24      0=
=2E0.0.0/0           to:192.168.1.2
>   211 16721 SNAT       all  --  *      eth0    192.168.199.0/24     0=
=2E0.0.0/0           to:192.168.1.2
>    24  8328 ACCEPT     udp  --  *      eth1    192.168.10.1         2=
55.255.255.255     udp spts:67:68 dpts:67:68
>     4  1388 ACCEPT     udp  --  *      eth2    192.168.199.1        2=
55.255.255.255     udp spts:67:68 dpts:67:68
>     0     0 DROP       all  --  *      *       0.0.0.0              0=
=2E0.0.0/0
root@fs:~# iptables -t mangle -nvL
> Chain PREROUTING (policy ACCEPT 1287K packets, 1508M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>
> Chain INPUT (policy ACCEPT 1212K packets, 1461M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>
> Chain FORWARD (policy ACCEPT 73581 packets, 47M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>
> Chain OUTPUT (policy ACCEPT 548K packets, 100M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>
> Chain POSTROUTING (policy ACCEPT 622K packets, 147M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
root@fs:~# ip route
> 192.168.11.2 dev tun0  proto kernel  scope link  src 192.168.11.1
> 192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.2
> 192.168.199.0/24 dev eth2  proto kernel  scope link  src 192.168.199.=
1
> 192.168.11.0/24 via 192.168.11.2 dev tun0
> 192.168.10.0/24 dev eth1  proto kernel  scope link  src 192.168.10.1
> 127.0.0.0/8 dev lo  scope link
> default via 192.168.1.1 dev eth0  metric 1
root@fs:~# ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: on
root@fs:~# ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> udp fragmentation offload: off
> generic segmentation offload: on
root@fs:~# ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: on
root@fs:~# uname -a
> Linux fs 2.6.34.4-FS #1 SMP Thu Aug 19 18:09:58 UTC 2010 i686 Intel(R=
) Pentium(R) D CPU 3.00GHz GenuineIntel GNU/Linux

