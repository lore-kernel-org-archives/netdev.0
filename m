From: Jan Engelhardt <jengelh@medozas.de>
Subject: sk->sk_socket seems to disappear before connection termination
Date: Wed, 10 Nov 2010 02:09:57 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Rafa=C5=82_Maj?= <rafal.maj.it@gmail.com>
To: Netfilter Developer Mailing List <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


Rafa=C5=82 reported this to us on IRC, paraphrasing what has been obser=
ved:

Using a simple rule like `iptables -A OUTPUT -p tcp --dport 80 -j LOG=20
--log-uid`, one can observe on creating a connection and terminating
it that the trailing packets have skb->sk->sk_socket =3D=3D NULL.
Is this intended? Is the socket not retained until after TCP has
sent out the closing exchange?

As I can reproduce:

$ telnet 134.76.13.21 80
Trying 134.76.13.21...
Connected to 134.76.13.21.
Escape character is '^]'.
^]
telnet> ^D
Connection closed.

[491419.500978] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.21 =
LEN=3D60 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35420 DF PROTO=3DTCP SPT=3D=
58613 DPT=3D80 WINDOW=3D5488 RES=3D0x00 SYN URGP=3D0 UID=3D25121 GID=3D=
100=20
[491419.511533] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.21 =
LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35421 DF PROTO=3DTCP SPT=3D=
58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0 UID=3D25121 GID=3D10=
0=20
[491420.052182] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.21 =
LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35422 DF PROTO=3DTCP SPT=3D=
58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK FIN URGP=3D0 UID=3D25121 GID=3D=
100=20
[491420.063619] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.21 =
LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35423 DF PROTO=3DTCP SPT=3D=
58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
