From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [RFC][PATCH] pcmcia: pcnet_cs.c removing useless condition
Date: Sun, 13 Sep 2009 00:38:49 +0530
Message-ID: <1252782529.3687.26.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	linux-pcmcia@lists.infradead.org,
	Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:51919 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbZILTI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Sep 2009 15:08:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[This is untested]

'if (i < NR_INFO)' will only true if we breaks from 'for (i =3D 0; i < =
NR_INFO; i++)'
So removing useless 'if (i < NR_INFO)'

This also fixed following compilation warning :

  CC [M]  drivers/net/pcmcia/pcnet_cs.o
drivers/net/pcmcia/pcnet_cs.c: In function =E2=80=98get_hwinfo=E2=80=99=
:
drivers/net/pcmcia/pcnet_cs.c:321: warning: =E2=80=98base=E2=80=99 may =
be used uninitialized in this function

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/pcmcia/pcnet_cs.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_c=
s.c
index 9ef1c1b..6a60227 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -339,12 +339,11 @@ static hw_info_t *get_hwinfo(struct pcmcia_device=
 *link)
 	base =3D &virt[hw_info[i].offset & (req.Size-1)];
 	if ((readb(base+0) =3D=3D hw_info[i].a0) &&
 	    (readb(base+2) =3D=3D hw_info[i].a1) &&
-	    (readb(base+4) =3D=3D hw_info[i].a2))
-	    break;
-    }
-    if (i < NR_INFO) {
-	for (j =3D 0; j < 6; j++)
-	    dev->dev_addr[j] =3D readb(base + (j<<1));
+	    (readb(base+4) =3D=3D hw_info[i].a2)) {
+		for (j =3D 0; j < 6; j++)
+		    dev->dev_addr[j] =3D readb(base + (j<<1));
+		break;
+	}
     }
=20
     iounmap(virt);
--=20
1.6.4.2


