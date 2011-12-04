From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() page recycling
Date: Sun, 04 Dec 2011 18:36:52 +0100
Message-ID: <1323020212.2762.147.camel@edumazet-laptop>
References: <1323018317.2762.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57918 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755017Ab1LDRg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 12:36:58 -0500
Received: by eaak14 with SMTP id k14so3646949eaa.19
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2011 09:36:57 -0800 (PST)
In-Reply-To: <1323018317.2762.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 04 d=C3=A9cembre 2011 =C3=A0 18:05 +0100, Eric Dumazet a =C3=
=A9crit :
> If our TCP_PAGE(sk) is not shared (page_count() =3D=3D 1), we can set=
 page
> offset to 0.
>=20
> This permits better filling of the pages on small to medium tcp write=
s.
>=20
> "tbench 16" results on my dev server (2x4x2 machine) :
>=20
> Before : 3072 MB/s
> After  : 3146 MB/s  (2.4 % gain)

By the way current linux tree on the same machine gets 2957 MB/s

So the combination of select_size() patch and this one gives
a 6.4 % gain.

Definitely worth the pain, isnt it ?
