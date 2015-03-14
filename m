From: "Leonhard Preis" <leonhard@pre.is>
Subject: iproute2 fails to work with certain device names
Date: Sun, 15 Mar 2015 00:05:45 +0100
Message-ID: <op.xvifrvrh5ica7l@skepsis.pre.is>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from noether.pre.is ([144.76.121.212]:55259 "EHLO noether.pre.is"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbbCNXLS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 19:11:18 -0400
Received: from localhost (localhost [127.0.0.1])
	by noether.pre.is (Postfix) with ESMTP id 30A9FA10E5
	for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 00:05:42 +0100 (CET)
Received: from noether.pre.is ([127.0.0.1])
	by localhost (noether.pre.is [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EOkdJ2eW5Y89 for <netdev@vger.kernel.org>;
	Sun, 15 Mar 2015 00:05:40 +0100 (CET)
Received: from skepsis.pre.is (chello080109127054.4.15.vie.surfer.at [80.109.127.54])
	by noether.pre.is (Postfix) with ESMTPSA id 785A2A102E
	for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 00:05:40 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

iproute2=E2=80=99s ip utility fails to execute commands properly if one=
 specifies =20
any of the four device names h, he, hel, and help and only prints out =20
usage information.

Expected behaviour for a non-existing device:

% ip link show dev =20
hello                                                                  =
                                                                       =
                            =20
:(
Device "hello" does not exist.

Expected behaviour for an existing device:

% ip link show dev lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mod=
e =20
DEFAULT group default
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

Behaviour observed for both existing and absent devices called either h=
, =20
he, hel or help:

% ip link show dev =20
hel                                                                    =
                                                                       =
                          =20
:(
Usage: ip link add [link DEV] [ name ] NAME
                    [ txqueuelen PACKETS ]
                    [ address LLADDR ]
                    [ broadcast LLADDR ]
                    [ mtu MTU ] [index IDX ]
                    [ numtxqueues QUEUE_COUNT ]
                    [ numrxqueues QUEUE_COUNT ]
                    type TYPE [ ARGS ]
        ip link delete DEV type TYPE [ ARGS ]

        ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]
	                  [ arp { on | off } ]
	                  [ dynamic { on | off } ]
	                  [ multicast { on | off } ]
	                  [ allmulticast { on | off } ]
	                  [ promisc { on | off } ]
	                  [ trailers { on | off } ]
	                  [ txqueuelen PACKETS ]
	                  [ name NEWNAME ]
	                  [ address LLADDR ]
	                  [ broadcast LLADDR ]
	                  [ mtu MTU ]
	                  [ netns PID ]
	                  [ netns NAME ]
			  [ alias NAME ]
	                  [ vf NUM [ mac LLADDR ]
				   [ vlan VLANID [ qos VLAN-QOS ] ]
				   [ rate TXRATE ] ]
				   [ spoofchk { on | off} ] ]
				   [ state { auto | enable | disable} ] ]
			  [ master DEVICE ]
			  [ nomaster ]
			  [ addrgenmode { eui64 | none } ]
        ip link show [ DEVICE | group GROUP ] [up] [master DEV] [type T=
YPE]
        ip link help [ TYPE ]

TYPE :=3D { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |
           bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |
           gre | gretap | ip6gre | ip6gretap | vti | nlmon |
           bond_slave }

I successfully reproduced this on Debian Wheezy (iproute2 version =20
3.16.0-2~bpo70+1) and Arch Linux (iproute2 version 3.19.0-1).

While the general origin of this problem seems quite clear, I=E2=80=99m=
 left to =20
wonder whether this is on purpose or not. Since I did not hit any other=
 =20
obstacles with the device name I chose I came to the conclusion that th=
is =20
may be a bug and it would be terrific if it could be fixed. For now I=E2=
=80=99ll =20
perhaps simply change my device name - another l at the end will do the=
 =20
job. ;)

Please let me know if I could be of any further assistance or if this =20
report is missing vital information.

Thank you!

Cheers,
Leonhard

PS: I read in another thread that this mailing list is the "bug tracker=
" =20
for iproute2. I hope that statement is still true. It was my best shot =
at =20
the correct bug tracker.

--=20
Mit freundlichen Gr=C3=BC=C3=9Fen // Avec mes meilleures salutations //=
 Best Regards
Leonhard Preis
