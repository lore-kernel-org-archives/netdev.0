From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 ethernet bonding problems
Date: Tue, 19 Jun 2007 00:59:40 +0200
Message-ID: <20070618225940.GA27773@electric-eye.fr.zoreil.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com> <20070418181333.GA2261@electric-eye.fr.zoreil.com> <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com> <20070427220918.GB24358@electric-eye.fr.zoreil.com> <9e246b4d0705011317t72bc9413u2b002b71ca3865e9@mail.gmail.com> <20070501204721.GB19212@electric-eye.fr.zoreil.com> <9e246b4d0705011359r208ce760yba6edda835ca67a6@mail.gmail.com> <20070501211754.GB17225@electric-eye.fr.zoreil.com> <9e246b4d0705021038q458ab32r1c4f7431e7bd0f1@mail.gmail.com> <9e246b4d0705021103o28a7dd02t7dc9021a1651c8f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tim Durack <tdurack@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37728 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933564AbXFRXBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 19:01:09 -0400
Content-Disposition: inline
In-Reply-To: <9e246b4d0705021103o28a7dd02t7dc9021a1651c8f8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tim Durack <tdurack@gmail.com> :
[snip]

Can you try 2.6.22-rc5 +
http://www.fr.zoreil.com/people/francois/misc/20070619-2.6.22-rc5-r8169-test.patch

It does not seem to work too bad here (tested with 2.6.22-rc5 + patch):

# grep bonding /etc/modprobe.conf
alias bond0 bonding
options bonding miimon=1000 mode=balance-rr

$ dmesg
[    0.000000] Linux version 2.6.22-rc5 (root@localhost.localdomain) (gcc version 4.1.1 20070105 (Red Hat 4.1.1-51)) #9 Tue Jun 19 00:19:24 CEST 2007
[...]
[   35.516210] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   35.516251] ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 17
[   35.516279] PCI: Setting latency timer of device 0000:01:00.0 to 64
[   35.516632] eth0: RTL8168b/8111b at 0xf8a08000, 00:13:8f:ea:b1:5d, XID 38000000 IRQ 17
[   35.523173] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   35.523204] ACPI: PCI Interrupt 0000:03:01.0[A] -> GSI 22 (level, low) -> IRQ 20
[   35.523473] eth1: RTL8110s at 0xf8a0a800, 00:09:5b:bd:c1:a5, XID 04000000 IRQ 20
[   35.526654] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[   35.526683] ACPI: PCI Interrupt 0000:03:02.0[A] -> GSI 23 (level, low) -> IRQ 21
[   35.526940] eth2: RTL8110s at 0xf8a0cc00, 00:09:5b:bd:c1:a5, XID 04000000 IRQ 21
[   35.581378] USB Universal Host Controller Interface driver v3.0
[   35.582010] ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 21
[   35.582028] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[...]
[   46.300540] Ethernet Channel Bonding Driver: v3.1.2 (January 20, 2007)
[   46.307134] bonding: MII link monitoring set to 1000 ms
[   50.515819] r8169: eth1: link up
[   50.519218] r8169: eth1: link up
[   50.539460] bonding: bond0: enslaving eth1 as an active interface with an up link.
[   50.656913] r8169: eth2: link up
[   50.660296] r8169: eth2: link up
[   50.679294] bonding: bond0: enslaving eth2 as an active interface with an up link.

$ ifconfig
bond0     Link encap:Ethernet  HWaddr 00:09:5B:BD:C1:A5
          inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::209:5bff:febd:c1a5/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:319 errors:0 dropped:0 overruns:0 frame:0
          TX packets:329 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:31583 (30.8 KiB)  TX bytes:30884 (30.1 KiB)

eth1      Link encap:Ethernet  HWaddr 00:09:5B:BD:C1:A5
          inet6 addr: fe80::209:5bff:febd:c1a5/64 Scope:Link
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:158 errors:0 dropped:0 overruns:0 frame:0
          TX packets:165 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:16228 (15.8 KiB)  TX bytes:15418 (15.0 KiB)
          Interrupt:20 Base address:0xa800

eth2      Link encap:Ethernet  HWaddr 00:09:5B:BD:C1:A5
          inet6 addr: fe80::209:5bff:febd:c1a5/64 Scope:Link
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:161 errors:0 dropped:0 overruns:0 frame:0
          TX packets:164 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:15355 (14.9 KiB)  TX bytes:15466 (15.1 KiB)
          Interrupt:21 Base address:0xcc00

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:560 (560.0 b)  TX bytes:560 (560.0 b)

# ethtool -S eth1
NIC statistics:
     tx_packets: 205
     rx_packets: 195
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 192
     broadcast: 1
     multicast: 2
     tx_aborted: 0
     tx_underrun: 0

# ethtool -S eth2
NIC statistics:
     tx_packets: 205
     rx_packets: 198
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 195
     broadcast: 2
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0

Let's play gently with the cables:

PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.276 ms
64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.184 ms
64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.195 ms
64 bytes from 192.168.1.1: icmp_seq=4 ttl=64 time=0.173 ms
64 bytes from 192.168.1.1: icmp_seq=5 ttl=64 time=0.212 ms
64 bytes from 192.168.1.1: icmp_seq=6 ttl=64 time=0.173 ms
64 bytes from 192.168.1.1: icmp_seq=7 ttl=64 time=0.198 ms
64 bytes from 192.168.1.1: icmp_seq=8 ttl=64 time=0.173 ms
64 bytes from 192.168.1.1: icmp_seq=9 ttl=64 time=0.200 ms
64 bytes from 192.168.1.1: icmp_seq=10 ttl=64 time=0.199 ms
64 bytes from 192.168.1.1: icmp_seq=11 ttl=64 time=0.185 ms
64 bytes from 192.168.1.1: icmp_seq=12 ttl=64 time=0.237 ms
64 bytes from 192.168.1.1: icmp_seq=13 ttl=64 time=0.217 ms
64 bytes from 192.168.1.1: icmp_seq=14 ttl=64 time=0.187 ms
64 bytes from 192.168.1.1: icmp_seq=15 ttl=64 time=0.222 ms
64 bytes from 192.168.1.1: icmp_seq=16 ttl=64 time=0.193 ms
64 bytes from 192.168.1.1: icmp_seq=17 ttl=64 time=0.189 ms
64 bytes from 192.168.1.1: icmp_seq=18 ttl=64 time=0.218 ms
64 bytes from 192.168.1.1: icmp_seq=19 ttl=64 time=0.207 ms
64 bytes from 192.168.1.1: icmp_seq=20 ttl=64 time=0.200 ms
64 bytes from 192.168.1.1: icmp_seq=21 ttl=64 time=0.193 ms
64 bytes from 192.168.1.1: icmp_seq=22 ttl=64 time=0.176 ms
64 bytes from 192.168.1.1: icmp_seq=23 ttl=64 time=0.216 ms
64 bytes from 192.168.1.1: icmp_seq=24 ttl=64 time=0.194 ms
64 bytes from 192.168.1.1: icmp_seq=25 ttl=64 time=0.218 ms
64 bytes from 192.168.1.1: icmp_seq=26 ttl=64 time=0.192 ms
64 bytes from 192.168.1.1: icmp_seq=27 ttl=64 time=0.173 ms
64 bytes from 192.168.1.1: icmp_seq=28 ttl=64 time=0.214 ms
64 bytes from 192.168.1.1: icmp_seq=29 ttl=64 time=0.236 ms
64 bytes from 192.168.1.1: icmp_seq=30 ttl=64 time=0.188 ms
64 bytes from 192.168.1.1: icmp_seq=31 ttl=64 time=0.186 ms
64 bytes from 192.168.1.1: icmp_seq=32 ttl=64 time=0.164 ms
64 bytes from 192.168.1.1: icmp_seq=33 ttl=64 time=0.213 ms
64 bytes from 192.168.1.1: icmp_seq=34 ttl=64 time=0.180 ms
64 bytes from 192.168.1.1: icmp_seq=35 ttl=64 time=0.211 ms
64 bytes from 192.168.1.1: icmp_seq=36 ttl=64 time=0.178 ms
64 bytes from 192.168.1.1: icmp_seq=37 ttl=64 time=0.209 ms
64 bytes from 192.168.1.1: icmp_seq=38 ttl=64 time=0.201 ms
64 bytes from 192.168.1.1: icmp_seq=39 ttl=64 time=0.205 ms
64 bytes from 192.168.1.1: icmp_seq=40 ttl=64 time=0.187 ms
64 bytes from 192.168.1.1: icmp_seq=41 ttl=64 time=0.190 ms
64 bytes from 192.168.1.1: icmp_seq=42 ttl=64 time=0.262 ms
64 bytes from 192.168.1.1: icmp_seq=43 ttl=64 time=0.198 ms

[...]
[   65.364228] eth2: no IPv6 routers present
[   65.815462] eth1: no IPv6 routers present
[ 1197.478365] r8169: eth2: link down
[ 1197.679547] bonding: bond0: link status definitely down for interface eth2, disabling it
[ 1201.812241] r8169: eth2: link up
[ 1202.726842] bonding: bond0: link status definitely up for interface eth2.
[ 1208.448707] r8169: eth1: link down
[ 1208.779295] bonding: bond0: link status definitely down for interface eth1, disabling it
[ 1211.483899] r8169: eth1: link up
[ 1211.810965] bonding: bond0: link status definitely up for interface eth1.

--
Ueimor
