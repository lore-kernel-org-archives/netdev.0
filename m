From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] xen-netback: Replace a variable initialisation by an
 assignment in read_xenbus_vif_flags()
Date: Sat, 2 Jan 2016 18:57:08 +0100
Message-ID: <56880F74.5040304@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56880DD4.2090806@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56880DD4.2090806@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 18:01:57 +0100

Replace an explicit initialisation for one local variable at the beginning
by an assignment.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/xen-netback/xenbus.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index d4947e1..aff963f 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -946,7 +946,7 @@ err: /* Regular return falls through with err == 0 */
 
 static int read_xenbus_vif_flags(struct backend_info *be)
 {
-	struct xenvif *vif = be->vif;
+	struct xenvif *vif;
 	struct xenbus_device *dev = be->dev;
 	unsigned int rx_copy;
 	int err, val;
@@ -968,13 +968,14 @@ static int read_xenbus_vif_flags(struct backend_info *be)
 	if (xenbus_scanf(XBT_NIL, dev->otherend,
 			 "feature-rx-notify", "%d", &val) < 0)
 		val = 0;
+	vif = be->vif;
 	if (!val) {
 		/* - Reduce drain timeout to poll more frequently for
 		 *   Rx requests.
 		 * - Disable Rx stall detection.
 		 */
-		be->vif->drain_timeout = msecs_to_jiffies(30);
-		be->vif->stall_timeout = 0;
+		vif->drain_timeout = msecs_to_jiffies(30);
+		vif->stall_timeout = 0;
 	}
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
-- 
2.6.3
