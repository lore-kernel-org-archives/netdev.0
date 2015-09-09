From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v2 2/2] xen-netfront: respect user provided max_queues
Date: Wed, 9 Sep 2015 11:23:06 +0100
Message-ID: <1441794186-26991-3-git-send-email-wei.liu2@citrix.com>
References: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:27019 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108AbbIIKXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 06:23:08 -0400
In-Reply-To: <1441794186-26991-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally that parameter was always reset to num_online_cpus during
module initialisation, which renders it useless.

The fix is to only set max_queues to num_online_cpus when user has not
provided a value.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e27e6d2..0b53bd9 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -2132,8 +2132,11 @@ static int __init netif_init(void)
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
 
-	/* Allow as many queues as there are CPUs, by default */
-	xennet_max_queues = num_online_cpus();
+	/* Allow as many queues as there are CPUs if user has not
+	 * specified a value.
+	 */
+	if (xenvif_max_queues == 0)
+		xenvif_max_queues = num_online_cpus();
 
 	return xenbus_register_frontend(&netfront_driver);
 }
-- 
2.1.4
