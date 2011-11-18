From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: routing bug?
Date: Fri, 18 Nov 2011 13:48:03 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1111181346480.17023@aurora>
References: <4EC648C9.8080405@uhulinux.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-84160418-1321620483=:17023"
Cc: Linux-Kernel-Mailinglist <linux-kernel@vger.kernel.org>,
	=?ISO-8859-15?Q?Tam=E1si_J=E1nos?= <janusz@uhulinux.hu>,
	netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Pozs=E1r_Bal=E1zs?= <pozsy@uhulinux.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EC648C9.8080405@uhulinux.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-84160418-1321620483=:17023
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

Added netdev list to CC:, there you should have a higher chance of a
usefull answer.

On Fri, 18 Nov 2011, Pozs=E1r Bal=E1zs wrote:

> Hi all,
>=20
> I have been struggling with this not easily reproducible issue since a wh=
ile.
> I am using linux kernel v3.1.0, and sometimes routing to a few IP address=
es
> does not work. What seems to happen is that instead of sending the packet=
 to
> the gateway, the kernel treats the destination address as local, and trie=
s to
> gets its MAC address via ARP.
>=20
> For example, now my current IP address is 172.16.1.104/24, the gateway is
> 172.16.1.254:
>=20
> |# ifconfig eth0 eth0      Link encap:Ethernet  HWaddr 00:1B:63:97:FC:DC
>           inet addr:172.16.1.104  Bcast:172.16.1.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:230772 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:171013 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:191879370 (182.9 Mb)  TX bytes:47173253 (44.9 Mb)
>           Interrupt:17
>=20
> # route -n
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags Metric Ref    Use I=
face
> 0.0.0.0         172.16.1.254    0.0.0.0         UG    0      0        0 e=
th0
> 172.16.1.0      0.0.0.0         255.255.255.0   U     1      0        0 e=
th0
> |
>=20
> I can ping a few addresses, but not 172.16.0.59:
>=20
> |# ping -c1 172.16.1.254
> PING 172.16.1.254 (172.16.1.254) 56(84) bytes of data.
> 64 bytes from 172.16.1.254: icmp_seq=3D1 ttl=3D64 time=3D0.383 ms
>=20
> --- 172.16.1.254 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 0.383/0.383/0.383/0.000 ms
> root@pozsybook:~# ping -c1 172.16.0.1
> PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
> 64 bytes from 172.16.0.1: icmp_seq=3D1 ttl=3D63 time=3D5.54 ms
>=20
> --- 172.16.0.1 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 5.545/5.545/5.545/0.000 ms
> root@pozsybook:~# ping -c1 172.16.0.2
> PING 172.16.0.2 (172.16.0.2) 56(84) bytes of data.
> 64 bytes from 172.16.0.2: icmp_seq=3D1 ttl=3D62 time=3D7.92 ms
>=20
> --- 172.16.0.2 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 7.925/7.925/7.925/0.000 ms
> root@pozsybook:~# ping -c1 172.16.0.59
> PING 172.16.0.59 (172.16.0.59) 56(84) bytes of data.
> From 172.16.1.104 icmp_seq=3D1 Destination Host Unreachable
>=20
> --- 172.16.0.59 ping statistics ---
> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
> |
>=20
> When trying to ping 172.16.0.59, I can see in tcpdump that an ARP req was
> sent:
>=20
> |# tcpdump -n -i eth0|grep ARP
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decod=
e
> listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
> 15:25:16.671217 ARP, Request who-has 172.16.0.59 tell 172.16.1.104, lengt=
h 28
> |
>=20
> and /proc/net/arp has an incomplete entry for 172.16.0.59:
>=20
> |# grep 172.16.0.59 /proc/net/arp
>=20
> 172.16.0.59      0x1         0x0         00:00:00:00:00:00     *        e=
th0
> |
>=20
> Please note, that 172.16.0.59 /is/ accessible from this LAN from other
> computers.
>=20
>=20
> Does anyone have any idea of what's going on? Thanks,
>=20
>=20
> Balazs Pozsar
>=20
> ps: I think it is related to this one: https://lkml.org/lkml/2011/11/16/2=
92
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20

--=20
Three may keep a secret, if two of them are dead.
- Ben F.
--8323328-84160418-1321620483=:17023--
