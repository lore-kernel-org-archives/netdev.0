From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] Removing dead code in /drivers/net/wan/hdlc_fr.c
Date: Sun, 20 Apr 2008 19:15:51 +0200
Message-ID: <m3lk385tx4.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39551 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754319AbYDTRPx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 13:15:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: C=E9dric Augonnet <Cedric.Augonnet@ens-lyon.fr>

Removing dead code in /drivers/net/wan/hdlc_fr.c
   =20
The local variable "prefix" is never used anymore, and the content of
this string appears a bit later, directly in a call to "alloc_netdev"
after doing exactly the same if/else test. So there seems to be no
point keeping those 4 lines anymore.
   =20
Signed-off-by: C=E9dric Augonnet <cedric.augonnet@ens-lyon.org>
Signed-off-by: Krzysztof Ha=B3asa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index c4ab032..520bb0b 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1090,10 +1090,6 @@ static int fr_add_pvc(struct net_device *frad, u=
nsigned int dlci, int type)
 	pvc_device *pvc =3D NULL;
 	struct net_device *dev;
 	int result, used;
-	char * prefix =3D "pvc%d";
-
-	if (type =3D=3D ARPHRD_ETHER)
-		prefix =3D "pvceth%d";
=20
 	if ((pvc =3D add_pvc(frad, dlci)) =3D=3D NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_add_pvc()\n",
