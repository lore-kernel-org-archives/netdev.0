From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] vxlan: correct typo in call to unregister_netdevice_queue
Date: Mon, 18 May 2015 13:51:24 -0400
Message-ID: <1431971484-23467-1-git-send-email-linville@tuxdriver.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48801 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbbERSAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 14:00:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By inspection, this appears to be a typo.  The gating comparison
involves vxlan->dev rather than dev.  In fact, dev is the iterator in
the preceding loop above but it is actually constant in the 2nd loop.

Use of dev seems to be a bad cut-n-paste from the prior call to
unregister_netdevice_queue.  Change dev to vxlan->dev, since that is
what is actually being checked.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/vxlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 27a5f954f8e9..21a0fbf1ed94 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2961,7 +2961,7 @@ static void __net_exit vxlan_exit_net(struct net *net)
 		 * to the list by the previous loop.
 		 */
 		if (!net_eq(dev_net(vxlan->dev), net))
-			unregister_netdevice_queue(dev, &list);
+			unregister_netdevice_queue(vxlan->dev, &list);
 	}
 
 	unregister_netdevice_many(&list);
-- 
2.1.0
