From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: IRDA: mcs7780.c
Date: Fri, 13 Feb 2009 14:14:17 +0100
Message-ID: <49957229.9060401@gmail.com>
References: <1234514947203.juha_motorsportcom.12982.AOyeEm8k4zVzAxDijub1SA@luukku.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-1?Q?Juha_Lepp=E4nen?= <juha_motorsportcom@luukku.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:25046 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760131AbZBMNOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 08:14:22 -0500
Received: by ey-out-2122.google.com with SMTP id 25so142474eya.37
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 05:14:18 -0800 (PST)
In-Reply-To: <1234514947203.juha_motorsportcom.12982.AOyeEm8k4zVzAxDijub1SA@luukku.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juha Lepp=E4nen wrote:
> Hi,
>=20
> In recent patch to file
>=20
> drivers/net/irda/mcs7780.c

That's this one:
http://www.spinics.net/lists/netdev/msg88746.html

[PATCH] IRDA: cnt is off by 1

> I noticed when checking the code around the patch ...
> In worst case do {...} while loop is executed
> 101 times --> mcs_get_reg() is executed 101 times...
> But rval is checked only 100 times.

Right, thanks.

> If you change the order of the && expressions inside while () to
>=20
> -        } while(cnt++ < 100 && (rval & MCS_IRINTX));
> +        } while((rval & MCS_IRINTX) && cnt++ < 100);

> If you also want exactly 100 maximum mcs_get_reg()
> tries ( now it is 101 ) ...

I don't think it really matters, does it?

> Happy hacking,
>=20
> Mr. Juha Lepp=E4nen
> Kuopio, Finland

You too.

------------------------------>8----------------8<---------------------=
---------
If no prior break occurs, cnt reaches 101 after the loop, so we are sti=
ll able
to change speed when cnt has become 100.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 7eafdca..8fdfb5a 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -583,9 +583,9 @@ static int mcs_speed_change(struct mcs_cb *mcs)
=20
 	do {
 		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
-	} while(cnt++ < 100 && (rval & MCS_IRINTX));
+	} while((rval & MCS_IRINTX) && cnt++ < 100);
=20
-	if(cnt >=3D 100) {
+	if (cnt > 100) {
 		IRDA_ERROR("unable to change speed\n");
 		ret =3D -EIO;
 		goto error;
