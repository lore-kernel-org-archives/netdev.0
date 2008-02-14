From: =?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>
Subject: [PATCH 06/14] drivers/net/arcnet/arcnet.c: Use time_* macros
Date: Thu, 14 Feb 2008 17:36:44 +0200
Message-ID: <1203003412-11594-7-git-send-email-caglar@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:49922 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753003AbYBNPjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 10:39:13 -0500
In-Reply-To: y
References: y
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before, time_before_eq, time_after, and time_after_e=
q are more robust for comparing jiffies against other values.

So following patch implements usage of the time_after() macro, defined =
at linux/jiffies.h, which deals with wrapping correctly

Cc: netdev@vger.kernel.org
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
index fde6758..537d661 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -283,7 +284,7 @@ struct arcnet_local {
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
1.5.3.7

