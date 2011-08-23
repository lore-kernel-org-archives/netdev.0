From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Tue, 23 Aug 2011 11:57:03 +0200
Message-ID: <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E5367CA.3090005@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51293 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1HWJ5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 05:57:03 -0400
Received: by wwf5 with SMTP id 5so6068917wwf.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 02:57:02 -0700 (PDT)
In-Reply-To: <4E5367CA.3090005@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 ao=C3=BBt 2011 =C3=A0 17:41 +0900, Ang Way Chuang a =C3=A9c=
rit :
> Hi all,
>=20
>     Sorry for cross-posting. I have a testbed setup on my VM
> environment that needs to use MLDv2 report message. My PIM router
> which is connected to a port on the bridge relies upon MLDv2 message
> to work. However, the setup failed to work after 2.6.39-rc2 or later.
> MLDv2 won't be forwarded to any slave ports bound to the bridge
> interface. Specifically, I track the cause down to this commit id:
>=20
>       ff9a57a62afbbe2d0f3a09af321f1fd7645f38a5
>=20
>     However, as soon as I disable multicast snooping on sysfs, MLDv2
> message can be forwarded again.
>=20
>     I am not knowledgeable on the subject of multicast snooping, but
> is this right behaviour for multicast snooping? IPv4 doesn't seem to
> suffer the same fate though, IGMP can be forwarded even if
> multicast_snooping is enabled. Thank you in advance.
>=20

Thanks very much for the report and your tracking.

Added some CC

I wonder if the  ff9a57a62afb commit doesnt uncover a prior bug, could
you try the following patch ?

Thanks !

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..51e3b2d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1520,6 +1520,7 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
 		err =3D pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto out;
+		icmp6h =3D icmp6_hdr(skb2);
 	}
=20
 	switch (skb2->ip_summed) {


