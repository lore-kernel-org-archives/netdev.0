From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v3 2/2] xen-netfront: respect user provided max_queues
Date: Thu, 10 Sep 2015 11:18:58 +0100
Message-ID: <1441880338-4911-3-git-send-email-wei.liu2@citrix.com>
References: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:57961 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbbIJKTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 06:19:00 -0400
In-Reply-To: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally that parameter was always reset to num_online_cpus during
module initialisation, which renders it useless.

The fix is to only set max_queues to num_online_cpus when user has not
provided a value.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
v3: fix copy-n-paste error to make netfront compile
---
 drivers/net/xen-netfront.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e27e6d2..b9c637a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -2132,8 +2132,11 @@ static int __init netif_init(void)
 
 	pr_info("Initialising Xen virtual ethernet driver\n");
 
-	/* Allow as many queues as there are CPUs, by default */
-	xennet_max_queues = num_online_cpus();
+	/* Allow as many queues as there are CPUs if user has not
+	 * specified a value.
+	 */
+	if (xennet_max_queues == 0)
+		xennet_max_queues = num_online_cpus();
 
 	return xenbus_register_frontend(&netfront_driver);
 }
-- 
2.1.4
