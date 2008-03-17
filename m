From: =?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>
Subject: [PATCH] drivers/net/arcnet/arcnet.c: Use time_* macros
Date: Mon, 17 Mar 2008 11:36:27 +0200
Message-ID: <1205746593-24820-5-git-send-email-caglar@pardus.org.tr>
References: <>
 <1205746593-24820-1-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-2-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-3-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-4-git-send-email-caglar@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:42586 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752617AbYCQJhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 05:37:14 -0400
In-Reply-To: <1205746593-24820-4-git-send-email-caglar@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before, time_before_eq, time_after, and time_after_e=
q are more robust for comparing jiffies against other values.

So following patch implements usage of the time_after() macro, defined =
at linux/jiffies.h, which deals with wrapping correctly

Cc: Jeff Garzik <jeff@garzik.org>
Cc: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
---
 drivers/net/arcnet/arcnet.c |    4 ++--
 include/linux/arcdevice.h   |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index c59c806..c298615 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -940,7 +940,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
=20
 			/* is the RECON info empty or old? */
 			if (!lp->first_recon || !lp->last_recon ||
-			    jiffies - lp->last_recon > HZ * 10) {
+			    time_after(jiffies, lp->last_recon + HZ * 10)) {
 				if (lp->network_down)
 					BUGMSG(D_NORMAL, "reconfiguration detected: cabling restored?\n")=
;
 				lp->first_recon =3D lp->last_recon =3D jiffies;
@@ -974,7 +974,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 					lp->num_recons =3D 1;
 				}
 			}
-		} else if (lp->network_down && jiffies - lp->last_recon > HZ * 10) {
+		} else if (lp->network_down && time_after(jiffies, lp->last_recon + =
HZ * 10)) {
 			if (lp->network_down)
 				BUGMSG(D_NORMAL, "cabling restored?\n");
 			lp->first_recon =3D lp->last_recon =3D 0;
diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index fde6758..9d33768 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -283,7 +283,7 @@ struct arcnet_local {
 	int next_buf, first_free_buf;
=20
 	/* network "reconfiguration" handling */
-	time_t first_recon,	/* time of "first" RECON message to count */
+	unsigned long first_recon,	/* time of "first" RECON message to count =
*/
 		last_recon;	/* time of most recent RECON */
 	int num_recons;		/* number of RECONs between first and last. */
 	bool network_down;	/* do we think the network is down? */
--=20
1.5.4.3

