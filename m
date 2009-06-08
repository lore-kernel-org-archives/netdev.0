From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH 1/1] bnx2: no need to check before vfreeing
Date: Mon, 08 Jun 2009 17:30:19 -0300
Message-ID: <4A2D74DB.7030001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:46513 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751893AbZFHUaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 16:30:21 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.13.1/8.13.1) with ESMTP id n58KSpWV029676
	for <netdev@vger.kernel.org>; Mon, 8 Jun 2009 17:28:51 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n58KUkOH1122778
	for <netdev@vger.kernel.org>; Mon, 8 Jun 2009 17:30:46 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n58KUK6E018243
	for <netdev@vger.kernel.org>; Mon, 8 Jun 2009 17:30:20 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check if a pointer is NULL before calling
vfree(), since vfree() function already check for it.

Signed-off-by: Breno Leit=C3=A3o <leitao@linux.vnet.ibm.com>
---
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b0cb29d..7d014dc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -545,8 +545,7 @@ bnx2_free_rx_mem(struct bnx2 *bp)
 						    rxr->rx_desc_mapping[j]);
 			rxr->rx_desc_ring[j] =3D NULL;
 		}
-		if (rxr->rx_buf_ring)
-			vfree(rxr->rx_buf_ring);
+		vfree(rxr->rx_buf_ring);
 		rxr->rx_buf_ring =3D NULL;
=20
 		for (j =3D 0; j < bp->rx_max_pg_ring; j++) {
@@ -556,8 +555,7 @@ bnx2_free_rx_mem(struct bnx2 *bp)
 						    rxr->rx_pg_desc_mapping[j]);
 			rxr->rx_pg_desc_ring[j] =3D NULL;
 		}
-		if (rxr->rx_pg_ring)
-			vfree(rxr->rx_pg_ring);
+		vfree(rxr->rx_pg_ring);
 		rxr->rx_pg_ring =3D NULL;
 	}
 }
