From: sjur.brandeland@stericsson.com
Subject: [PATCH 2/2] caif: performance bugfix - allow radio stack to prioritize
 packets.
Date: Mon, 11 Apr 2011 22:11:30 +0200
Message-ID: <1302552691-11874-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:53720 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846Ab1DKULh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2011 16:11:37 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI0096H83BEF90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:35 +0200 (CEST)
Received: from localhost.localdomain ([80.203.137.187])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LJI007NQ83ANZZ0@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 11 Apr 2011 22:11:35 +0200 (CEST)
In-reply-to: <1302552691-11874-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

    In the CAIF Payload message the Packet Type indication must be set =
to
    UNCLASSIFIED in order to allow packet prioritization in the modem's
    network stack. Otherwise TCP-Ack is not prioritized in the modems
    transmit queue.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfdgml.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index a4ce294..0382dec 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -13,6 +13,7 @@
 #include <net/caif/cfsrvl.h>
 #include <net/caif/cfpkt.h>
=20
+
 #define container_obj(layr) ((struct cfsrvl *) layr)
=20
 #define DGM_CMD_BIT  0x80
@@ -83,6 +84,7 @@ static int cfdgml_receive(struct cflayer *layr, struc=
t cfpkt *pkt)
=20
 static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt)
 {
+	u8 packet_type;
 	u32 zero =3D 0;
 	struct caif_payload_info *info;
 	struct cfsrvl *service =3D container_obj(layr);
@@ -94,7 +96,9 @@ static int cfdgml_transmit(struct cflayer *layr, stru=
ct cfpkt *pkt)
 	if (cfpkt_getlen(pkt) > DGM_MTU)
 		return -EMSGSIZE;
=20
-	cfpkt_add_head(pkt, &zero, 4);
+	cfpkt_add_head(pkt, &zero, 3);
+	packet_type =3D 0x08; /* B9 set - UNCLASSIFIED */
+	cfpkt_add_head(pkt, &packet_type, 1);
=20
 	/* Add info for MUX-layer to route the packet out. */
 	info =3D cfpkt_info(pkt);
--=20
1.7.0.4

