From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 7 Sep 2010 02:13:46 -0300
Message-ID: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
References: <AANLkTi=_heUejVf-wmEcKd910gVtpD7Hr=cZ_cs2Q8n9@mail.gmail.com>
 <AANLkTike9biiUvAhckJKHCB6dyS4PzHgFFPF5RNEw4PP@mail.gmail.com> <1283834219.2585.455.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60177 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab0IGFOI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:14:08 -0400
Received: by fxm13 with SMTP id 13so2795661fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 22:14:06 -0700 (PDT)
In-Reply-To: <1283834219.2585.455.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 1:36 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 07 septembre 2010 =C3=A0 01:20 -0300, =E3=83=84 Leandro Melo=
 de Sales a
> =C3=A9crit :
>> Hi all,
>> =C2=A0 =C2=A0We are facing a not expected behavior (at least for us)=
 from the
>> TCP stack under Linux. We need to write 78 bytes per writing using
>> write() function. But instead of sending 78 bytes TCP implementation
>> in Linux sends 48 bytes and later 30 bytes. We then started to debug
>> the implementation, but although we got some progress on this, I hav=
e
>> decided to ask in this list if someone can anticipate provide me mor=
e
>> information why TCP is not sending 78 at once, in addition to have a=
ny
>> clarification about if it is possible to force TCP sends 78 bytes in
>> each write() function call.
>> =C2=A0 =C2=A0I have tried many alternatives: set TCP_CORK; used sock=
et API to
>> write a fixed 78 bytes per write() function call; and so forth). Als=
o,
>> I know that TCP is a byte-stream protocol and this decision is made =
by
>> many different factors, such as cwd size, mss and so forth, but 78
>> bytes is too small to split it in two different packets. Our
>> application works as expected under Windows, it sends 78 bytes at
>> once.
>>
>> =C2=A0 =C2=A0In this way, any comment from the list regarding this i=
ssue will be
>> kindly accepted and helpful.
>
>
> Could you send a tcpdump of such session, with say first 10 packets ?
>
>

=46or this moment, this is all that I have, I can't not use TCPDump
right now, but I think the below information are what you'd like to
have:

Under Linux:

Source=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 Dest.=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Flags
192.168.0.34=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [SYN] Seq=
=3D0 Win=3D5840 Len=3D0 MSS=3D1460
TSV=3D105155 TSER=3D0 WS=3D7
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.34=C2=A0=C2=A0=C2=A0 [SYN, ACK=
] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
192.168.0.34=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D1 Win=3D5840 Len=3D0
192.168.0.34=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [PSH, ACK=
] Seq=3D1 Ack=3D1 Win=3D5840 Len=3D48
192.168.0.34=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [PSH, ACK=
] Seq=3D49 Ack=3D1 Win=3D5840 Len=3D30
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.34=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D49 Win=3D78 Len=3D0
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.34=C2=A0=C2=A0=C2=A0 [RST, ACK=
] Seq=3D1 Ack=3D79 Win=3D78 Len=3D0

Under Windows:

Source=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 Dest.=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Flags
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [SYN] Seq=
=3D0 Win=3D64240 Len=3D0 MSS=3D1460
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.35=C2=A0=C2=A0=C2=A0 [SYN, ACK=
] Seq=3D0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D1 Win=3D64272 Len=3D0
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [PSH, ACK=
] Seq=3D1 Ack=3D1 Win=3D64272 Len=3D78
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.35=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D79 Win=3D78 Len=3D0
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [PSH, ACK=
] Seq=3D79 Ack=3D1 Win=3D64272 Len=3D78
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.35=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D157 Win=3D78 Len=3D0
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [PSH, ACK=
] Seq=3D157 Ack=3D1 Win=3D64272 Len=3D78
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.35=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D1 Ack=3D235 Win=3D78 Len=3D0
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [FIN, ACK=
] Seq=3D235 Ack=3D1 Win=3D64272 Len=3D0
192.168.0.70=C2=A0=C2=A0=C2=A0 192.168.0.35=C2=A0=C2=A0=C2=A0 [FIN, ACK=
] Seq=3D1 Ack=3D236 Win=3D78 Len=3D0
192.168.0.35=C2=A0=C2=A0=C2=A0 192.168.0.70=C2=A0=C2=A0=C2=A0 [ACK] Seq=
=3D236 Ack=3D2 Win=3D64272 Len=3D0

To simplify, below is a very summarized source code used to connect to
the remove server. I have tried to use sendall() function from python
socket API and it does not work either. I have implemented similar
program in C, but nothing new was produced.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

import socket
host =3D '192.168.0.70'
port =3D 70

hex_CONNECT =3D "<78 hex bytes -- suppressed>"
hex_COMMAND1 =3D "<78 hex bytes -- suppressed>"
hex_COMMAND6 =3D "<78 hex bytes -- suppressed>"

s =3D socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((host, port))
s.setsockopt(socket.SOL_TCP, socket.TCP_CORK, 1)
s.send(unhexlify(hex_CONNECT))
s.send(unhexlify(hex_COMMAND1))
s.send(unhexlify(hex_COMMAND6))
s.close()

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Leandro
