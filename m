From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 12/14] ipw2100: Fix deadlock detected by lockdep
Date: Mon, 21 Aug 2006 11:38:52 +0800
Message-ID: <20060821033852.GA5425@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3614 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932589AbWHUDkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:40:47 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix by removing dependency between priv->action_sem and rtnl semaphore.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2100.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

fcf4f163e01e6c5128e578fdbe1e778bc16fa1c0
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index e955db4..5d5dab6 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6254,13 +6254,14 @@ static int ipw2100_pci_init_one(struct p
 	 * member to call a function that then just turns and calls ipw2100_up.
 	 * net_dev->init is called after name allocation but before the
 	 * notifier chain is called */
-	mutex_lock(&priv->action_mutex);
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling register_netdev.\n");
-		goto fail_unlock;
+		goto fail;
 	}
+
+	mutex_lock(&priv->action_mutex);
 	registered = 1;
 
 	IPW_DEBUG_INFO("%s: Bound to %s\n", dev->name, pci_name(pci_dev));
-- 
1.2.6
