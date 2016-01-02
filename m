From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] xen-netback: Delete an unnecessary goto statement in
 connect_rings()
Date: Sat, 2 Jan 2016 18:55:29 +0100
Message-ID: <56880F11.7030303@users.sourceforge.net>
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
Date: Sat, 2 Jan 2016 17:50:21 +0100

One goto statement referred to a source code position directly behind it.
Thus omit such an unnecessary jump.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/xen-netback/xenbus.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 7f2895d..d4947e1 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -933,13 +933,11 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 	/* Map the shared frame, irq etc. */
 	err = xenvif_connect(queue, tx_ring_ref, rx_ring_ref,
 			     tx_evtchn, rx_evtchn);
-	if (err) {
+	if (err)
 		xenbus_dev_fatal(dev, err,
 				 "mapping shared-frames %lu/%lu port tx %u rx %u",
 				 tx_ring_ref, rx_ring_ref,
 				 tx_evtchn, rx_evtchn);
-		goto err;
-	}
 
 err: /* Regular return falls through with err == 0 */
 	kfree(xspath);
-- 
2.6.3
