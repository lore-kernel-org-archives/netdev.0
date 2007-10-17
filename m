From: Krzysztof Oledzki <olel@ans.pl>
Subject: BUG: unable to handle kernel NULL pointer dereference at virtual
 address 000000b0
Date: Wed, 17 Oct 2007 08:40:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710170833071.21430@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1952729816-1192603248=:21430"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:43146 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbXJQGkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 02:40:53 -0400
Received: from bizon.gios.gov.pl (olel@localhost6 [IPv6:::1])
	by bizon.gios.gov.pl (8.14.1/8.14.1) with ESMTP id l9H6enjo011952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 08:40:51 +0200
Received: from localhost (olel@localhost)
	by bizon.gios.gov.pl (8.14.1/8.14.1/Submit) with ESMTP id l9H6emuO011949
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 08:40:49 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1952729816-1192603248=:21430
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

Today I found in my logs:

BUG: unable to handle kernel NULL pointer dereference at virtual address 00=
0000b0
  printing eip:
78395f65
*pde =3D 00000000
Oops: 0000 [#1]
PREEMPT SMP
CPU:    0
EIP:    0060:[<78395f65>]    Not tainted VLI
EFLAGS: 00210286   (2.6.22.9 #1)
EIP is at __ip_route_output_key+0x412/0x722
eax: 80000000   ebx: 00000000   ecx: 5dd2b1c3   edx: 00000000
esi: 00000000   edi: d44c7e30   ebp: ec8c4980   esp: d44c7ddc
ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
Process smtpd (pid: 12479, ti=3Dd44c6000 task=3D9e759510 task.ti=3Dd44c6000=
)
Stack: d44c7e7c d44c7e7c d44c7eb8 00000000 d44c7e7c 00000000 00000000 00000=
005
        00000000 ffffffff 5dd2b1c3 00000000 00000000 00000000 00000000 0000=
0000
        00000000 00000000 00000000 00000000 00000000 00030000 00000000 d44c=
7e7c
Call Trace:
  [<78396280>] ip_route_output_flow+0xb/0x3e
  [<783b2b29>] ip4_datagram_connect+0x1c9/0x308
  [<783ba70a>] inet_dgram_connect+0x45/0x4e
  [<7837135e>] sys_connect+0x72/0x9c
  [<78371607>] sock_map_fd+0x41/0x4a
  [<7840d1b1>] _spin_lock+0x33/0x3e
  [<7840d623>] _spin_unlock+0x25/0x3b
  [<78371607>] sock_map_fd+0x41/0x4a
  [<78372792>] sys_socketcall+0x8f/0x242
  [<7813e99c>] trace_hardirqs_on+0x122/0x14c
  [<78103dc6>] sysenter_past_esp+0x8f/0x99
  [<78103d96>] sysenter_past_esp+0x5f/0x99
  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: fa e0 00 00 00 75 07 c6 44 24 56 05 eb 14 81 fa f0 00 00 00 0f 84 e1 =
02 00 00 84 c0 0f 84 d9 02 00 00 8b 44 24 0c 0d 00 00 00 80 <f6> 86 b0 00 0=
0 00 08 0f 44 44 24 0c 89 44 24 0c b8 01 00 00 00
EIP: [<78395f65>] __ip_route_output_key+0x412/0x722 SS:ESP 0068:d44c7ddc

Shortly before it there was:
Oct 17 07:17:55 cougar postfix/master[3400]: warning: process /usr/lib/post=
fix/smtpd pid 12479 killed by signal 11

Best regards,


 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1952729816-1192603248=:21430--
