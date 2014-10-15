From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4i : Fix -Wmaybe-uninitialized warning.
Date: Wed, 15 Oct 2014 00:26:47 -0700
Message-ID: <1413358007-16980-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, kxie@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44472
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751239AbaJOH1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 03:27:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Identified by kbuild test robot. csk family is always set to be AF_INET or 
AF_INET6, so skb will always be initialized to some value but there is no harm 
in silencing the warning anyways.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Fixes : f42bb57c61fd ('cxgb4i : Fix -Wunused-function warning')
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index 8c3003b..3e0a0d3 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -758,7 +758,7 @@ static int act_open_rpl_status_to_errno(int status)
 
 static void csk_act_open_retry_timer(unsigned long data)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct cxgbi_sock *csk = (struct cxgbi_sock *)data;
 	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(csk->cdev);
 	void (*send_act_open_func)(struct cxgbi_sock *, struct sk_buff *,
-- 
2.1.2
