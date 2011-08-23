From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Tue, 23 Aug 2011 15:10:27 +0200
Message-ID: <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E5367CA.3090005@sfc.wide.ad.jp>
	 <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E539DA8.1070504@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54757 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab1HWNK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 09:10:26 -0400
Received: by wwf5 with SMTP id 5so92711wwf.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 06:10:25 -0700 (PDT)
In-Reply-To: <4E539DA8.1070504@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 ao=C3=BBt 2011 =C3=A0 21:31 +0900, Ang Way Chuang a =C3=A9c=
rit :
> Sorry for the blurb. I hope I've configured thunderbird properly to
> send in plain text. Hope you received my reply. I tried your patch on
> 3.0.3 and it didn't fix the problem.


Thanks for trying !

Ok could you please try following patch then ?

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..e9b32a3 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1497,7 +1497,7 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
 	if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
 		goto out;
=20
-	len -=3D offset - skb_network_offset(skb2);
+	len -=3D offset;
=20
 	__skb_pull(skb2, offset);
 	skb_reset_transport_header(skb2);
@@ -1520,6 +1520,7 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
 		err =3D pskb_trim_rcsum(skb2, len);
 		if (err)
 			goto out;
+		icmp6h =3D icmp6_hdr(skb2);
 	}
=20
 	switch (skb2->ip_summed) {


