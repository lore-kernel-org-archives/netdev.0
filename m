From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/3] xen-netfront: fix locking in connect error path
Date: Thu, 31 Jul 2014 17:38:22 +0100
Message-ID: <1406824704-2275-2-git-send-email-david.vrabel@citrix.com>
References: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:48493 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbaGaQic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 12:38:32 -0400
In-Reply-To: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no queues could be created when connecting to the backend, one of the
error paths would deadlock.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 055222b..1cc46d0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -2001,7 +2001,7 @@ abort_transaction_no_dev_fatal:
 	info->queues = NULL;
 	rtnl_lock();
 	netif_set_real_num_tx_queues(info->netdev, 0);
-	rtnl_lock();
+	rtnl_unlock();
  out:
 	return err;
 }
-- 
1.7.10.4
