From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 09 Jan 2012 10:58:46 +0100
Message-ID: <1326103126.2407.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
	 <20120105.132637.2130515220408371607.davem@davemloft.net>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
	 <1326095038.2627.4.camel@edumazet-laptop>
	 <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65535 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2AIJ6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 04:58:51 -0500
Received: by bkcjm19 with SMTP id jm19so1374324bkc.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 01:58:50 -0800 (PST)
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 janvier 2012 =C3=A0 10:36 +0100, Manfred Rudigier a =C3=A9c=
rit :

> I have tried your suggested steal sequence, but it crashed.=20
> I see that there is also a destructor - when I use the skb_orphan fun=
ction (which calls the destructor) like this it works:
>=20
> 	skb_new->sk =3D skb->sk;
> 	skb_orphan(skb);
> 	kfree_skb(skb);
>=20
> Is this the correct solution?

I dont think so.

destructor and sk are coupled, you cant steal one and let the other
untouched.
