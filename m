From: Ralf Baechle <ralf@linux-mips.org>
Subject: [SLHC 2/4] Convert to kzalloc
Date: Thu, 13 Jul 2006 12:10:48 +0100
Message-ID: <20060713111048.GA19938@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:32650 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751528AbWGMLKs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 07:10:48 -0400
Received: from localhost.localdomain ([127.0.0.1]:6102 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133633AbWGMLKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 12:10:47 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/net/slhc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

Index: linux-net/drivers/net/slhc.c
===================================================================
--- linux-net.orig/drivers/net/slhc.c	2006-07-09 02:47:58.000000000 +0100
+++ linux-net/drivers/net/slhc.c	2006-07-10 01:35:51.000000000 +0100
@@ -94,27 +94,24 @@ slhc_init(int rslots, int tslots)
 	register struct cstate *ts;
 	struct slcompress *comp;
 
-	comp = (struct slcompress *)kmalloc(sizeof(struct slcompress),
+	comp = (struct slcompress *)kzalloc(sizeof(struct slcompress),
 					    GFP_KERNEL);
 	if (! comp)
 		goto out_fail;
-	memset(comp, 0, sizeof(struct slcompress));
 
 	if ( rslots > 0  &&  rslots < 256 ) {
 		size_t rsize = rslots * sizeof(struct cstate);
-		comp->rstate = (struct cstate *) kmalloc(rsize, GFP_KERNEL);
+		comp->rstate = (struct cstate *) kzalloc(rsize, GFP_KERNEL);
 		if (! comp->rstate)
 			goto out_free;
-		memset(comp->rstate, 0, rsize);
 		comp->rslot_limit = rslots - 1;
 	}
 
 	if ( tslots > 0  &&  tslots < 256 ) {
 		size_t tsize = tslots * sizeof(struct cstate);
-		comp->tstate = (struct cstate *) kmalloc(tsize, GFP_KERNEL);
+		comp->tstate = (struct cstate *) kzalloc(tsize, GFP_KERNEL);
 		if (! comp->tstate)
 			goto out_free2;
-		memset(comp->tstate, 0, tsize);
 		comp->tslot_limit = tslots - 1;
 	}
 
