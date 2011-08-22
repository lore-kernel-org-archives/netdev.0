From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Mon, 22 Aug 2011 13:47:38 +0200
Message-ID: <1314013658.2307.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
	 <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
	 <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48825 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab1HVLrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 07:47:36 -0400
Received: by wyg24 with SMTP id 24so3417473wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 04:47:35 -0700 (PDT)
In-Reply-To: <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 13:43 +0200, Eric Dumazet a =C3=A9cri=
t :

> This adds a race for lockless SNMP readers (in be_get_stats64())
>=20
> They can see the 32bit value going backward.
>=20
> You have to be very careful to read the *acc once, and write it once.

The "write once" is the only requirement.

Something like :

u32 newval =3D hi(*acc) + val;

if (wrapped)
	newval +=3D 65536;
ACCESS_ONCE(*acc) =3D newval;



