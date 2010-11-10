From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sk->sk_socket seems to disappear before connection termination
Date: Wed, 10 Nov 2010 06:47:17 +0100
Message-ID: <1289368037.2700.14.camel@edumazet-laptop>
References: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	=?UTF-8?Q?Rafa=C5=82?= Maj <rafal.maj.it@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 10 novembre 2010 =C3=A0 02:09 +0100, Jan Engelhardt a =C3=A9=
crit :
> Hi,
>=20
>=20
> Rafa=C5=82 reported this to us on IRC, paraphrasing what has been obs=
erved:
>=20
> Using a simple rule like `iptables -A OUTPUT -p tcp --dport 80 -j LOG=
=20
> --log-uid`, one can observe on creating a connection and terminating
> it that the trailing packets have skb->sk->sk_socket =3D=3D NULL.
> Is this intended? Is the socket not retained until after TCP has
> sent out the closing exchange?
>=20
> As I can reproduce:
>=20
> $ telnet 134.76.13.21 80
> Trying 134.76.13.21...
> Connected to 134.76.13.21.
> Escape character is '^]'.
> ^]
> telnet> ^D
> Connection closed.
>=20
> [491419.500978] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.2=
1 LEN=3D60 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35420 DF PROTO=3DTCP SP=
T=3D58613 DPT=3D80 WINDOW=3D5488 RES=3D0x00 SYN URGP=3D0 UID=3D25121 GI=
D=3D100=20
> [491419.511533] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.2=
1 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35421 DF PROTO=3DTCP SP=
T=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0 UID=3D25121 GID=3D=
100=20
> [491420.052182] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.2=
1 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35422 DF PROTO=3DTCP SP=
T=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK FIN URGP=3D0 UID=3D25121 =
GID=3D100=20
> [491420.063619] IN=3D OUT=3Dtun0 SRC=3D134.76.2.163 DST=3D134.76.13.2=
1 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D35423 DF PROTO=3DTCP SP=
T=3D58613 DPT=3D80 WINDOW=3D86 RES=3D0x00 ACK URGP=3D0=20

Hmmm... skb->sk->sk_socket is really NULL ?

Are you sure its not skb->sk->sk_socket->file which is NULL ?

In this case, you might need to use sock_i_uid() / sock_i_ino() as a
fallback ? (expensive because they take a rwlock)




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
