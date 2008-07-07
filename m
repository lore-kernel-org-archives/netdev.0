From: Krzysztof Oledzki <olel@ans.pl>
Subject: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 7 Jul 2008 23:01:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1790150514-1215464489=:15459"
Cc: kaber@trash.net, greearb@candelatech.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:35441 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122AbYGGVBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:01:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1790150514-1215464489=:15459
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

I have a problem that I'm not able to connect from selected linux hosts to=
=20
a newly installed Netware 6.5 server. After two days of debugging I=20
discovered that the problem seems to be caused by an insufficient padding=
=20
of a .1q tagged packets.

Currently, if a packet is too short, it is extended to 60(+4) octets for=20
both untagged and tagged ones. Unfortunately, when a .1Q tag is removed on=
=20
a receive side, such packet is likely to be dropped as it may become too=20
short (56 bytes):

This is a normal (working) ping with 84B (IP) + 14B (eth hdr) =3D 98B octet=
s:
# ping -c 2 192.168.0.194
PING 192.168.0.194 (192.168.0.194) 56(84) bytes of data.
64 bytes from 192.168.0.194: icmp_seq=3D1 ttl=3D128 time=3D0.137 ms
64 bytes from 192.168.0.194: icmp_seq=3D2 ttl=3D128 time=3D0.141 ms

This is a shorter (working) ping with 46 (IP) + 14B (eth hdr) =3D 60B octet=
s:
# ping -c 2 192.168.0.194 -s 18
PING 192.168.0.194 (192.168.0.194) 18(46) bytes of data.
26 bytes from 192.168.0.194: icmp_seq=3D1 ttl=3D128 time=3D0.137 ms
26 bytes from 192.168.0.194: icmp_seq=3D2 ttl=3D128 time=3D0.144 ms

This one does not work (45+14 =3D 59):=20
# ping -c 2 192.168.0.194 -s 17
PING 192.168.0.194 (192.168.0.194) 17(45) bytes of data.

--- 192.168.0.194 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms

I believe that my problem can be solved if we start padding .1Q packets=20
with 4 more octets but I'm not able to find a proper place where to fix=20
it.

I also found a very similar report:
  http://mail.opensolaris.org/pipermail/networking-discuss/2007-March/01458=
5.html
  http://mail.opensolaris.org/pipermail/networking-discuss/2007-March/01458=
8.html

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1790150514-1215464489=:15459--
