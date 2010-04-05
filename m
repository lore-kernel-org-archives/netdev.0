From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Mon, 05 Apr 2010 17:56:52 +0200
Message-ID: <1270483012.4722.161.camel@edumazet-laptop>
References: <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	 <20100401143805.1f83a161@notabene.brown>
	 <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
	 <20100401.002319.236233308.davem@davemloft.net>
	 <w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, neilb@suse.de,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:38986 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755255Ab0DEP46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 11:56:58 -0400
Received: by bwz1 with SMTP id 1so2875798bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 08:56:56 -0700 (PDT)
In-Reply-To: <w2n412e6f7f1004050223j3e15df91tcdf133670c636a85@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 17:23 +0800, Changli Gao a =C3=A9crit :

> I found this from the man page of FreeBSD's connect(2).
>=20
>      Generally, stream sockets may successfully connect() only
>      once; datagram sockets may use connect() multiple times to chang=
e their
>      association.  Datagram sockets may dissolve the association by c=
onnecting
>      to an invalid address, such as a null address.
>=20
> And this from the man page of Darwin's connect(2).
>=20
>      Datagram sockets may dissolve the association by connecting to a=
n
>      invalid address, such as a null address or an address with the a=
ddress
>      family set to AF_UNSPEC (the error EAFNOSUPPORT will be harmless=
ly
>      returned).
>=20
> Since null address behavior has been defined by the others. I think
> Linux should be compatible with the others. So the  patch submitted o=
n
> this by me should not been applied. I'll work out another patch later=
=2E
>=20

As pointed by David, no sane application would use this facility until =
a
decade, I wonder why you insist so much for this minor detail.

Solaris man page extract :

"Datagram sockets can dissolve the association by connecting to a null
address."

What is a null address ?=20

1) A null pointer ?=20
2) a pointer to a zone, but length of this zone is 0
3) Or a pointer to a zone filled with NULL bytes ?

Linux implements the later interpretation. Its more than enough.

If a NULL pointer was implemented, man pages would use the following
words : "Datagram sockets can dissolve the association by connecting to
a NULL pointer (NULL second argument to connect())."

If you submit a patch to change connect() behavior, dont forget to send
appropriate changes to Michael, because in the end, nobody but you know=
s
how things are supposed to work if not documented.

MAN-PAGES: MANUAL PAGES FOR LINUX -- Sections 2, 3, 4, 5, and 7
M:      Michael Kerrisk <mtk.manpages@gmail.com>
W:      http://www.kernel.org/doc/man-pages



