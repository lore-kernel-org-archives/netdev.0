From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v3 1/2] xen-netback: respect user provided max_queues
Date: Thu, 10 Sep 2015 11:18:57 +0100
Message-ID: <1441880338-4911-2-git-send-email-wei.liu2@citrix.com>
References: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>
To: Xen-devel <xen-devel@lists.xenproject.org>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:35993 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbbIJKTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 06:19:02 -0400
In-Reply-To: <1441880338-4911-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Originally that parameter was always reset to num_online_cpus during
module initialisation, which renders it useless.

The fix is to only set max_queues to num_online_cpus when user has not
provided a value.

Reported-by: Johnny Strom <johnny.strom@linuxsolutions.fi>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Reviewed-by: David Vrabel <david.vrabel@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/netback.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 42569b9..f585c6a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -2105,8 +2105,11 @@ static int __init netback_init(void)
 	if (!xen_domain())
 		return -ENODEV;
 
-	/* Allow as many queues as there are CPUs, by default */
-	xenvif_max_queues = num_online_cpus();
+	/* Allow as many queues as there are CPUs if user has not
+	 * specified a value.
+	 */
+	if (xenvif_max_queues == 0)
+		xenvif_max_queues = num_online_cpus();
 
 	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
 		pr_info("fatal_skb_slots too small (%d), bump it to XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
-- 
2.1.4
