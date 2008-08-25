From: Timo =?utf-8?q?Weing=C3=A4rtner?= <timo@tiwe.de>
Subject: problem with tagged/untagged vlan and bridging
Date: Mon, 25 Aug 2008 16:03:37 +0200
Message-ID: <200808251603.41301.timo@tiwe.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1772232.0eorVvjmze";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mini002.webpack.hosteurope.de ([80.237.130.131]:35362 "EHLO
	mini002.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754759AbYHYO1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 10:27:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1772232.0eorVvjmze
Content-Type: multipart/mixed;
  boundary="Boundary-01=_6ursIkRjEYWyqHh"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_6ursIkRjEYWyqHh
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

Last Thursday I bought a wireless access point with multi-ssid (D-Link DWL=
=20
2100AP). Management of the AP and RADIUS stuff is done without VLAN tags, t=
he=20
first SSID is also without tags. The other SSIDs have VLAN IDs configurable.

My first SSID is quasi-disabled by having the RADIUS always reject access=20
requests, a second uses VLAN 3.

The access point is connected to my Xen machine on dev hme2. The VLAN=20
subdevice hme2.3 is enslaved to br_3, the main device hme2 to br_4.

Wireshark is showing that packets coming in to hme2 with VLAN 3 go to br_4=
=20
with VLAN tags instead of hme2.3 and then br_3. When I remove hme2 from br_=
4=20
everything works the way I expect it to, but the AP has no connection to th=
e=20
RADIUS (on vif4.0) anymore.

I expect the VLAN subdevices to grab their packets from the master first an=
d=20
leave the rest for the bridge.

Am I doing anything wrong or is this a bug?

I use 2.6.16.62 with the sunhme vlan patch[1] because of complications with=
=20
Xen. "git log v2.6.16..HEAD -- net/8021q/ net/bridge/" does not appear to=20
show anyhing that might have fixed it.

Some config info is attached. Ask for more if you need it.


Thanks in advance
Timo

[1] a5a97263a9fd6a94f954d41ae3233ea65a90bd8a

--Boundary-01=_6ursIkRjEYWyqHh
Content-Type: text/plain;
  name="ip l"
Content-Transfer-Encoding: 7bit

1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0
3: ip6tnl0: <NOARP> mtu 1460 qdisc noop
    link/tunnel6 :: brd ::
4: hme0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 08:00:20:f4:c8:f4 brd ff:ff:ff:ff:ff:ff
5: hme1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 08:00:20:f4:c8:f5 brd ff:ff:ff:ff:ff:ff
6: hme2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 08:00:20:f4:c8:f6 brd ff:ff:ff:ff:ff:ff
7: hme3: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 08:00:20:f4:c8:f7 brd ff:ff:ff:ff:ff:ff
8: skge0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:13:d4:78:9c:2c brd ff:ff:ff:ff:ff:ff
9: eth1394: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ieee1394 00:11:d8:00:00:4f:97:e4 brd ff:ff:ff:ff:ff:ff:ff:ff
10: hme2.3: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 08:00:20:f4:c8:f6 brd ff:ff:ff:ff:ff:ff
11: br_1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:13:d4:78:9c:2c brd ff:ff:ff:ff:ff:ff
12: br_2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 08:00:20:f4:c8:f7 brd ff:ff:ff:ff:ff:ff
13: br_3: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 08:00:20:f4:c8:f6 brd ff:ff:ff:ff:ff:ff
14: br_4: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 08:00:20:f4:c8:f6 brd ff:ff:ff:ff:ff:ff
15: vif1.0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
16: vif1.0.1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
17: vif1.0.2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
18: vif1.0.3: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
19: vif2.0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
20: vif3.0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
21: vif4.0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
22: vif4.0.1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff
23: vif4.0.4: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether fe:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff

--Boundary-01=_6ursIkRjEYWyqHh
Content-Type: text/plain;
  name="brctl show"
Content-Transfer-Encoding: 7bit

bridge name     bridge id               STP enabled     interfaces
br_1            8000.0013d4789c2c       no              hme0
                                                        hme1
                                                        skge0
                                                        vif1.0.1
                                                        vif2.0
                                                        vif3.0
                                                        vif4.0.1
br_2            8000.080020f4c8f7       no              hme3
                                                        vif1.0.2
br_3            8000.080020f4c8f6       no              hme2.3
                                                        vif1.0.3
br_4            8000.080020f4c8f6       no              hme2
                                                        vif4.0.4

--Boundary-01=_6ursIkRjEYWyqHh
Content-Type: text/plain;
  name="proc_net_vlan_*"
Content-Transfer-Encoding: quoted-printable

VLAN Dev name    | VLAN ID                                           =20
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD                        =20
hme2.3         | 3  | hme2                                           =20
vif1.0.1       | 1  | vif1.0                                         =20
vif1.0.2       | 2  | vif1.0                                         =20
vif1.0.3       | 3  | vif1.0                                         =20
vif4.0.1       | 1  | vif4.0                                         =20
vif4.0.4       | 4  | vif4.0                                         =20
hme2.3  VID: 3   REORDER_HDR: 1  dev->priv_flags: 1                  =20
         total frames received           15                          =20
          total bytes received         7108                          =20
      Broadcast/Multicast Rcvd           12                          =20

      total frames transmitted         3381
       total bytes transmitted       428070
            total headroom inc            1
           total encap on xmit         3381
Device: hme2                              =20
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:                                     =20
vif1.0.1  VID: 1         REORDER_HDR: 1  dev->priv_flags: 1    =20
         total frames received        72723                    =20
          total bytes received     43367278                    =20
      Broadcast/Multicast Rcvd         3885

      total frames transmitted        92633
       total bytes transmitted     25327305
            total headroom inc         4917
           total encap on xmit        92633
Device: vif1.0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
vif1.0.2  VID: 2         REORDER_HDR: 1  dev->priv_flags: 1
         total frames received        77309
          total bytes received      8640874
      Broadcast/Multicast Rcvd            1

      total frames transmitted        59797
       total bytes transmitted     43315354
            total headroom inc        30882
           total encap on xmit        59797
Device: vif1.0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
vif1.0.3  VID: 3         REORDER_HDR: 1  dev->priv_flags: 1
         total frames received         3822
          total bytes received       416076
      Broadcast/Multicast Rcvd         3809

      total frames transmitted           15
       total bytes transmitted         7318
            total headroom inc            0
           total encap on xmit           15
Device: vif1.0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
vif4.0.1  VID: 1         REORDER_HDR: 1  dev->priv_flags: 1
         total frames received         4910
          total bytes received      1264893
      Broadcast/Multicast Rcvd           10

      total frames transmitted        10220
       total bytes transmitted      1392795
            total headroom inc          103
           total encap on xmit        10220
Device: vif4.0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:
vif4.0.4  VID: 4         REORDER_HDR: 1  dev->priv_flags: 1
         total frames received         2829
          total bytes received       322432
      Broadcast/Multicast Rcvd            1

      total frames transmitted         5293
       total bytes transmitted      4141739
            total headroom inc         2730
           total encap on xmit         3467
Device: vif4.0
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
EGRESSS priority Mappings:

--Boundary-01=_6ursIkRjEYWyqHh--

--nextPart1772232.0eorVvjmze
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQEcBAABAgAGBQJIsru6AAoJEEn74FOC+06t4+8H/2SXOZuqwnezai9MS1WFOoPx
FZQV5/TnT0oSvPQKFtiSpuN4oxtRYB1dBo3WONHEujJh2Vnz+3FL9BbJvQh5TpVe
57SGMdFsGA0XxuuwP7J2q/gZQfnE87UFzilsGDBzpuxpkiZgnbmM+RSilOpWOVTc
2vstvZnq85Nrae/VldwqkbE2UIZzo01pAkcDP03A9eklnn0CVES5KWPAVV5F9wEL
SBBTh9GRv7RbPT3yBXYD+wT5uGhTlohg5u3yoPlHwNAKYuhSiyQSPYThCSwW7qUg
K6ix/ACQU7ORXitrD8JEYiECqfkfiXhAy6y79v6S45KRX+R2pzCzddxqPkIpBDk=
=qcva
-----END PGP SIGNATURE-----

--nextPart1772232.0eorVvjmze--
