From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH net] xen/netback: Properly initialize credit_bytes
Date: Mon, 11 May 2015 18:04:25 +0100
Message-ID: <1431363865-27317-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wei.liu2@citrix.com>, Ross Lagerwall <ross.lagerwall@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18979 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbEKREh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:04:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue
struct") introduced a regression when moving queue-specific data into
the queue struct by failing to set the credit_bytes field. This
prevented bandwidth limiting from working. Initialize the field as it
was done before multiqueue support was added.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
Acked-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/xenbus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d8dbf5..1be3ef3 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -793,7 +793,7 @@ static void connect(struct backend_info *be)
 			goto err;
 		}
 
-		queue->remaining_credit = credit_bytes;
+		queue->remaining_credit = queue->credit_bytes = credit_bytes;
 		queue->credit_usec = credit_usec;
 
 		err = connect_rings(be, queue);
-- 
2.1.0
