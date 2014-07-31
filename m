From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 3/3] xen-netfront: print correct number of queues
Date: Thu, 31 Jul 2014 17:38:24 +0100
Message-ID: <1406824704-2275-4-git-send-email-david.vrabel@citrix.com>
References: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61406 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbaGaQic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 12:38:32 -0400
In-Reply-To: <1406824704-2275-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When less than the requested number of queues could be created, include
the actual number in the warning (instead of the requested number).

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 0b133a3..28204bc 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1815,8 +1815,8 @@ static int xennet_create_queues(struct netfront_info *info,
 
 		ret = xennet_init_queue(queue);
 		if (ret < 0) {
-			dev_warn(&info->netdev->dev, "only created %d queues\n",
-				 num_queues);
+			dev_warn(&info->netdev->dev,
+				 "only created %d queues\n", i);
 			num_queues = i;
 			break;
 		}
-- 
1.7.10.4
