From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 6/8] gigaset: remove unused structure member rcvbytes
Date: Thu, 14 May 2009 00:44:18 +0200 (CEST)
Message-ID: <20090514-patch-06.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:38977 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756746AbZEMWoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:34 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The B channel data structure member rcvbytes was never set to
anything else but zero, so drop it.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/asyncdata.c |    5 ++---
 drivers/isdn/gigaset/common.c    |    2 --
 drivers/isdn/gigaset/gigaset.h   |    1 -
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
index 2a4ce96..234cc5d 100644
--- a/drivers/isdn/gigaset/asyncdata.c
+++ b/drivers/isdn/gigaset/asyncdata.c
@@ -174,9 +174,8 @@ byte_stuff:
 
 				if (unlikely(fcs != PPP_GOODFCS)) {
 					dev_err(cs->dev,
-					    "Packet checksum at %lu failed, "
-					    "packet is corrupted (%u bytes)!\n",
-					    bcs->rcvbytes, skb->len);
+				"Checksum failed, %u bytes corrupted!\n",
+						skb->len);
 					compskb = NULL;
 					gigaset_rcv_error(compskb, cs, bcs);
 					error = 1;
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 79c9b0f..e4141bf 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -565,8 +565,6 @@ static struct bc_state *gigaset_initbcs(struct bc_state *bcs,
 	gig_dbg(DEBUG_INIT, "setting up bcs[%d]->at_state", channel);
 	gigaset_at_init(&bcs->at_state, bcs, cs, -1);
 
-	bcs->rcvbytes = 0;
-
 #ifdef CONFIG_GIGASET_DEBUG
 	bcs->emptycount = 0;
 #endif
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index d5f0110..a2f6125 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -384,7 +384,6 @@ struct bc_state {
 	int trans_up;			/* Counter of packages (upstream) */
 
 	struct at_state_t at_state;
-	unsigned long rcvbytes;
 
 	__u16 fcs;
 	struct sk_buff *skb;
-- 
1.6.2.1.214.ge986c

