From: Ralf Baechle <ralf@linux-mips.org>
Subject: [SLHC 3/4] Remove useless casts
Date: Thu, 13 Jul 2006 12:12:53 +0100
Message-ID: <20060713111253.GA20095@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:41098 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751518AbWGMLMx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 07:12:53 -0400
Received: from localhost.localdomain ([127.0.0.1]:15062 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133633AbWGMLMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 12:12:52 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 drivers/net/slhc.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

Index: linux-net/drivers/net/slhc.c
===================================================================
--- linux-net.orig/drivers/net/slhc.c	2006-07-10 01:35:51.000000000 +0100
+++ linux-net/drivers/net/slhc.c	2006-07-10 01:35:56.000000000 +0100
@@ -94,14 +94,13 @@ slhc_init(int rslots, int tslots)
 	register struct cstate *ts;
 	struct slcompress *comp;
 
-	comp = (struct slcompress *)kzalloc(sizeof(struct slcompress),
-					    GFP_KERNEL);
+	comp = kzalloc(sizeof(struct slcompress), GFP_KERNEL);
 	if (! comp)
 		goto out_fail;
 
 	if ( rslots > 0  &&  rslots < 256 ) {
 		size_t rsize = rslots * sizeof(struct cstate);
-		comp->rstate = (struct cstate *) kzalloc(rsize, GFP_KERNEL);
+		comp->rstate = kzalloc(rsize, GFP_KERNEL);
 		if (! comp->rstate)
 			goto out_free;
 		comp->rslot_limit = rslots - 1;
@@ -109,7 +108,7 @@ slhc_init(int rslots, int tslots)
 
 	if ( tslots > 0  &&  tslots < 256 ) {
 		size_t tsize = tslots * sizeof(struct cstate);
-		comp->tstate = (struct cstate *) kzalloc(tsize, GFP_KERNEL);
+		comp->tstate = kzalloc(tsize, GFP_KERNEL);
 		if (! comp->tstate)
 			goto out_free2;
 		comp->tslot_limit = tslots - 1;
@@ -138,9 +137,9 @@ slhc_init(int rslots, int tslots)
 	return comp;
 
 out_free2:
-	kfree((unsigned char *)comp->rstate);
+	kfree(comp->rstate);
 out_free:
-	kfree((unsigned char *)comp);
+	kfree(comp);
 out_fail:
 	return NULL;
 }
