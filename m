From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH for-next 2/3] iw_cxgb4: remove false error log entry
Date: Fri,  5 Feb 2016 11:43:29 +0530
Message-ID: <1454652810-25086-3-git-send-email-hariprasad@chelsio.com>
References: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Cc: dledford@redhat.com, davem@davemloft.net,
	swise@opengridcomputing.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:60919 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751184AbcBEGLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 01:11:15 -0500
In-Reply-To: <1454652810-25086-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't log errors if a listening endpoint is going away when procesing a
PASS_ACCEPT_REQ message.  This can happen.  Change the error printk to
a PDBG() debug log entry

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 704680471567..fe4e81b993d3 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -2399,8 +2399,7 @@ static int pass_accept_req(struct c4iw_dev *dev, struct sk_buff *skb)
 	}
 
 	if (state_read(&parent_ep->com) != LISTEN) {
-		printk(KERN_ERR "%s - listening ep not in LISTEN\n",
-		       __func__);
+		PDBG("%s - listening ep not in LISTEN\n", __func__);
 		goto reject;
 	}
 
-- 
2.3.4
