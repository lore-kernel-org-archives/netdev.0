From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH net v2] xen/netback: Properly initialize credit_bytes
Date: Wed, 27 May 2015 11:44:32 +0100
Message-ID: <1432723472-7793-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xen-devel@lists.xenproject.org>, Wei Liu <wei.liu2@citrix.com>,
	"Ian Campbell" <ian.campbell@citrix.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19275 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbE0Kol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 06:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue
struct") introduced a regression when moving queue-specific data into
the queue struct by failing to set the credit_bytes field. This
prevented bandwidth limiting from working. Initialize the field as it
was done before multiqueue support was added.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---

Changed in v2: Fixed multiple-assignment.

 drivers/net/xen-netback/xenbus.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3d8dbf5..fee0241 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -793,6 +793,7 @@ static void connect(struct backend_info *be)
 			goto err;
 		}
 
+		queue->credit_bytes = credit_bytes;
 		queue->remaining_credit = credit_bytes;
 		queue->credit_usec = credit_usec;
 
-- 
2.1.0
