From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] red: give a hint about burst value
Date: Thu, 01 Dec 2011 12:04:31 +0100
Message-ID: <1322737471.2335.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322688891.2602.15.camel@edumazet-laptop>
	 <1322689213.2602.18.camel@edumazet-laptop>
	 <1322691053.2602.24.camel@edumazet-laptop>
	 <CAA93jw7TZj3Gd-KiVwr3Qwta4RpDKKV9QxGc+fyGc_+-9r1tLw@mail.gmail.com>
	 <1322693086.2602.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50751 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab1LALEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 06:04:34 -0500
Received: by qyk7 with SMTP id 7so165553qyk.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 03:04:33 -0800 (PST)
In-Reply-To: <1322693086.2602.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 23:44 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 30 novembre 2011 =C3=A0 23:35 +0100, Dave Taht a =C3=A9cr=
it :
>=20
> > One of my other problems is when I try to size red (or choke) appro=
priately
> > (or so I think) for GigE bandwidths and queue depths, it would fail
> > to calculate the ewma value.
>=20
> Do you have one example of such failure ?
>=20

Oh I understand your burst value is really too small.

Stephen, can we add this helper to iproute2 ?

[PATCH iproute2] red: try to give hint about burst value

Reported-by: Dave Taht <dave.taht@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/tc/tc_red.c b/tc/tc_red.c
index 66658ca..a65435e 100644
--- a/tc/tc_red.c
+++ b/tc/tc_red.c
@@ -56,8 +56,11 @@ int tc_red_eval_ewma(unsigned qmin, unsigned burst, =
unsigned avpkt)
 	double W =3D 0.5;
 	double a =3D (double)burst + 1 - (double)qmin/avpkt;
=20
-	if (a < 1.0)
+	if (a < 1.0) {
+		fprintf(stderr, "tc_red_eval_ewma() burst %u is too small ?"
+				" Try burst %u\n", burst, 1 + qmin/avpkt);
 		return -1;
+	}
 	for (wlog=3D1; wlog<32; wlog++, W /=3D 2) {
 		if (a <=3D (1 - pow(1-W, burst))/W)
 			return wlog;
