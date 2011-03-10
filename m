From: j223yang@asset.uwaterloo.ca
Subject: [patch]iwch_cm: fix possible null pointer
Date: Thu, 10 Mar 2011 12:23:48 -0500
Message-ID: <20110310172348.GA10787@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes bugzilla #9583:
https://bugzilla.kernel.org/show_bug.cgi?id=9583

The patch adds NULL check for 'ep->com.cm_id' before derefenrence, since
'ep->com.cm_id' is testing for NULL before. But it depends on the relationship
between 'status' and 'ep->com.cm_id'.

Signed-off-by: Jinqiu Yang<crindy646@gmail.com>
---
 iwch_cm.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c	2011-03-10 11:20:13.641039456 -0500
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c	2011-03-10 11:39:03.346164807 -0500
@@ -746,7 +746,8 @@ static void connect_reply_upcall(struct 
 		ep->com.cm_id->event_handler(ep->com.cm_id, &event);
 	}
 	if (status < 0) {
-		ep->com.cm_id->rem_ref(ep->com.cm_id);
+		if (ep->com.cm_id)
+			ep->com.cm_id->rem_ref(ep->com.cm_id);
 		ep->com.cm_id = NULL;
 		ep->com.qp = NULL;
 	}
