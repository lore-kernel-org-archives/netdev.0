From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: Fix confusing insmod error code for C101 too.
Date: Sun, 20 Apr 2008 19:10:56 +0200
Message-ID: <m3myno5u5b.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ZSM1387.piap.pl ([195.187.100.11]:54391 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754164AbYDTRK5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 13:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WAN: Fix confusing insmod error code for C101 too.

Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index c4c8eab..c2cc42f 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -402,7 +402,7 @@ static int __init c101_init(void)
 #ifdef MODULE
 		printk(KERN_INFO "c101: no card initialized\n");
 #endif
-		return -ENOSYS;	/* no parameters specified, abort */
+		return -EINVAL;	/* no parameters specified, abort */
 	}
=20
 	printk(KERN_INFO "%s\n", version);
@@ -420,11 +420,11 @@ static int __init c101_init(void)
 			c101_run(irq, ram);
=20
 		if (*hw =3D=3D '\x0')
-			return first_card ? 0 : -ENOSYS;
+			return first_card ? 0 : -EINVAL;
 	}while(*hw++ =3D=3D ':');
=20
 	printk(KERN_ERR "c101: invalid hardware parameters\n");
-	return first_card ? 0 : -ENOSYS;
+	return first_card ? 0 : -EINVAL;
 }
=20
=20
