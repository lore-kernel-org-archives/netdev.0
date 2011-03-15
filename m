From: David Miller <davem@davemloft.net>
Subject: Re: [Bloat] shaper team forming up
Date: Tue, 15 Mar 2011 15:51:51 -0700 (PDT)
Message-ID: <20110315.155151.226785359.davem@davemloft.net>
References: <5BC42741-852B-4699-BA5D-D70B8D610D96@gmail.com>
	<1300134277.2649.19.camel@edumazet-laptop>
	<1300164166.2649.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chromatix99@gmail.com, d@taht.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752042Ab1COWvO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 18:51:14 -0400
In-Reply-To: <1300164166.2649.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Mar 2011 05:42:46 +0100

> Le lundi 14 mars 2011 =E0 21:24 +0100, Eric Dumazet a =E9crit :
>=20
> David, it seems ip_tos2prio is wrong on its 2nd entry :

Indeed, and in context, this is simply a thinko which has survived sinc=
e
ECN support first got added to the tree, here's the relevant hunk:

--------------------
@@ -152,23 +152,29 @@ struct dst_ops ipv4_dst_ops =3D
 	sizeof(struct rtable),
 };
=20
+#ifdef CONFIG_INET_ECN
+#define ECN_OR_COST(class)	TC_PRIO_##class
+#else
+#define ECN_OR_COST(class)	TC_PRIO_FILLER
+#endif
+
 __u8 ip_tos2prio[16] =3D {
 	TC_PRIO_BESTEFFORT,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(FILLER),
 	TC_PRIO_BESTEFFORT,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(BESTEFFORT),
 	TC_PRIO_BULK,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(BULK),
 	TC_PRIO_BULK,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(BULK),
 	TC_PRIO_INTERACTIVE,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(INTERACTIVE),
 	TC_PRIO_INTERACTIVE,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(INTERACTIVE),
 	TC_PRIO_INTERACTIVE_BULK,
-	TC_PRIO_FILLER,
+	ECN_OR_COST(INTERACTIVE_BULK),
 	TC_PRIO_INTERACTIVE_BULK,
-	TC_PRIO_FILLER
+	ECN_OR_COST(INTERACTIVE_BULK)
 };
