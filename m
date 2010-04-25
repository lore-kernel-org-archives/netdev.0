From: "R. Weinedel" <r.weinedel@yahoo.de>
Subject: vlan performance issue on outgoing traffic
Date: Mon, 26 Apr 2010 00:20:39 +0200
Message-ID: <4BD4C037.2070003@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp114.plus.mail.re1.yahoo.com ([69.147.102.77]:40264 "HELO
	smtp114.plus.mail.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751239Ab0DYW1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 18:27:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hallo,

I have an performance issue with vlan interfaces on an Debian Lenny
server. The problem occurs only on outgoing traffic from the vlan
interfaces. They use only half of the available bandwidth - (490 Mbit/s
measured with iperf ). Incoming traffic is handled @ 950 Mbit/s and is
fine. The issue remains even with no switch and an direct connection
between pc and server on the same nic. Removing (on server) the vlans
from eth0 and configure one net on eth0 results in full speed (950
Mbit/s) in both directions. Even another nic (onboard nvidia3 - mod
forcedeth) couldn't solve it. I tested only in the same networking
segment (vlan) without the need for ip forwarding or NAT, but the issue
occurs on all my vlan's.

All values were taken with iperf between the server and an ubuntu 9.04
workstation (and vice versa). I have controlled (w. ethtool / stats fro=
m
switch) that all connection was 1000-BaseT/full duplex. It looks like
some kind of trafficshaping to me, but i don't use tc, qos,tos nor othe=
r
priority handling.

The network ist quite simple: One Server, one switch and then the
workstations. No need for cascading or using (r)stp.

Here some information about my network:

Switch: Netgear GSM7224 Layer 2 managed switch, FW 6.2.0.14
(independent, issue remains on direct connection).

Server: Debian Lenny, kernel 2.6.26-2,

NIC: Intel Corporation 82541PI Gigabit Ethernet Con. (e1000 module).
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: umbg
        Wake-on: g
        Current message level: 0x00000007 (7)
        Link detected: yes

8021q:
filename:       /lib/modules/2.6.26-2-686/kernel/net/8021q/8021q.ko
version:        1.8
license:        GPL
alias:          rtnl-link-vlan
srcversion:     A61E1168F65EE335A91D4E1
depends:
vermagic:       2.6.26-2-686 SMP mod_unload modversions 686

VLAN: #/proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth0.5         | 5  | eth0
eth0.101       | 101  | eth0
eth0.90        | 90  | eth0

IFCONFIG:
eth0      Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
          inet6-Adresse: fe80::20e:cff:febc:4343/64
G=FCltigkeitsbereich:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
          RX packets:28140829 errors:0 dropped:218 overruns:0 frame:0
          TX packets:44994420 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:1000
          RX bytes:3472864138 (3.2 GiB)  TX bytes:3908682627 (3.6 GiB)

eth0.5    Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
          inet Adresse:XXX.YYY.5.1  Bcast:XXX.YYY.5.255  Maske:255.255.=
255.0
          inet6-Adresse: fe80::20e:cff:febc:4343/64
G=FCltigkeitsbereich:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
          RX packets:77807 errors:0 dropped:0 overruns:0 frame:0
          TX packets:69699 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:0
          RX bytes:57578233 (54.9 MiB)  TX bytes:7782844 (7.4 MiB)

eth0.90   Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
          inet Adresse:XXX.YYY.90.1  Bcast:XXX.YYY.90.255=20
Maske:255.255.255.0
          inet6-Adresse: fe80::20e:cff:febc:4343/64
G=FCltigkeitsbereich:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
          RX packets:457850 errors:0 dropped:0 overruns:0 frame:0
          TX packets:913988 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:0
          RX bytes:23824841 (22.7 MiB)  TX bytes:1311485281 (1.2 GiB)

eth0.101  Link encap:Ethernet  Hardware Adresse 00:0e:0c:bc:43:43
          inet Adresse:XXX.YYY.101.1  Bcast:XXX.YYY.101.255=20
Maske:255.255.255.0
          inet6-Adresse: fe80::20e:cff:febc:4343/64
G=FCltigkeitsbereich:Verbindung
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metrik:1
          RX packets:24856818 errors:0 dropped:0 overruns:0 frame:0
          TX packets:41608593 errors:0 dropped:0 overruns:0 carrier:0
          Kollisionen:0 Sendewarteschlangenl=E4nge:0
          RX bytes:423116676 (403.5 MiB)  TX bytes:3855703636 (3.5 GiB)

ROUTE: #route -n
Ziel            Router          Genmask         Flags Metric Ref    Use
Iface
XXX.YYY.101.0   0.0.0.0         255.255.255.0   U     0      0        0
eth0.101
XXX.YYY.5.0     0.0.0.0         255.255.255.0   U     0      0        0
eth0.5
XXX.YYY.90.0    0.0.0.0         255.255.255.0   U     0      0        0
eth0.90
0.0.0.0         192.168.5.4     0.0.0.0         UG    0      0        0
eth0.5

Can someone give me a hint, where my search for an solution should be
going on ?

Many thanks !
Regards
Ralf Weinedel
=46alkensee/Germany


