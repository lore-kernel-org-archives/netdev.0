From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] fsl/fman: fix a leak in tgec_free()
Date: Thu, 24 Nov 2016 14:20:43 +0300
Message-ID: <20161124111931.GK17225@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>,
        Igal Liberman <igal.liberman@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:40034 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964981AbcKXLY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 06:24:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We set "tgec->cfg" to NULL before passing it to kfree().  There is no
need to set it to NULL at all.  Let's just delete it.

Fixes: 57ba4c9b56d8 ("fsl/fman: Add FMan MAC support")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I haven't tested this.  It occurs to me that this code might be
something to paper over a use after free bug by changing it to a leak
instead.

It applies to net-master.

diff --git a/drivers/net/ethernet/freescale/fman/fman_tgec.c b/drivers/net/ethernet/freescale/fman/fman_tgec.c
index efabb04..4b0f3a5 100644
--- a/drivers/net/ethernet/freescale/fman/fman_tgec.c
+++ b/drivers/net/ethernet/freescale/fman/fman_tgec.c
@@ -722,9 +722,6 @@ int tgec_free(struct fman_mac *tgec)
 {
 	free_init_resources(tgec);
 
-	if (tgec->cfg)
-		tgec->cfg = NULL;
-
 	kfree(tgec->cfg);
 	kfree(tgec);
 
