From: Krzysztof Oledzki <olel@ans.pl>
Subject: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Thu, 13 Sep 2007 19:55:09 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709131942370.27961@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-167197584-1189706109=:27961"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:52922 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395AbXIMSYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 14:24:34 -0400
Received: from bizon.gios.gov.pl (olel@localhost6 [IPv6:::1])
	by bizon.gios.gov.pl (8.14.1/8.14.1) with ESMTP id l8DHtA0o028531
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 19:55:12 +0200
Received: from localhost (olel@localhost)
	by bizon.gios.gov.pl (8.14.1/8.14.1/Submit) with ESMTP id l8DHt9q8028528
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 19:55:10 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-167197584-1189706109=:27961
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

It seems that after some not very recent changes udp and tcp packes=20
carring data send by a loopback have incorrect cksum:

UDP:
# echo test|nc -u 127.0.0.1 1111

# tcpdump -i lo -n -v -v port 1111
tcpdump: listening on lo, link-type EN10MB (Ethernet), capture size 96 byte=
s
19:43:39.340576 IP (tos 0x0, ttl  64, id 15179, offset 0, flags [DF], proto=
: UDP (17), length: 33) 127.0.0.1.49512 > 127.0.0.1.1111: [bad udp cksum 17=
4c!] UDP, length 5

TCP:
# echo test|nc -u 127.0.0.1 1111

tcpdump: listening on lo, link-type EN10MB (Ethernet), capture size 96 byte=
s
*Correct:
19:44:27.692614 IP (tos 0x0, ttl  64, id 32100, offset 0, flags [DF], proto=
: TCP (6), length: 60) 127.0.0.1.53804 > 127.0.0.1.1111: S, cksum 0xfd54 (c=
orrect), 3426125135:3426125135(0) win 32792 <mss 16396,sackOK,timestamp 191=
2797227 0,nop,wscale 7>
19:44:27.692674 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: TC=
P (6), length: 60) 127.0.0.1.1111 > 127.0.0.1.53804: S, cksum 0xea3f (corre=
ct), 3427916955:3427916955(0) ack 3426125136 win 32768 <mss 16396,sackOK,ti=
mestamp 1912797227 1912797227,nop,wscale 7>
19:44:27.692711 IP (tos 0x0, ttl  64, id 32101, offset 0, flags [DF], proto=
: TCP (6), length: 52) 127.0.0.1.53804 > 127.0.0.1.1111: ., cksum 0xd263 (c=
orrect), 1:1(0) ack 1 win 257 <nop,nop,timestamp 1912797227 1912797227>

*Incorrect:
19:44:27.692831 IP (tos 0x0, ttl  64, id 32102, offset 0, flags [DF], proto=
: TCP (6), length: 57) 127.0.0.1.53804 > 127.0.0.1.1111: P, cksum 0xfe2d (i=
ncorrect (-> 0xe07c), 1:6(5) ack 1 win 257 <nop,nop,timestamp 1912797227 19=
12797227>

*Correct:
19:44:27.692859 IP (tos 0x0, ttl  64, id 9399, offset 0, flags [DF], proto:=
 TCP (6), length: 52) 127.0.0.1.1111 > 127.0.0.1.53804: ., cksum 0xd25f (co=
rrect), 1:1(0) ack 6 win 256 <nop,nop,timestamp 1912797227 1912797227>

Tested on:
  - 2.6.22.6
  - 2.6.21.7
  - 2.6.20.11

Best regards,


 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-167197584-1189706109=:27961--
