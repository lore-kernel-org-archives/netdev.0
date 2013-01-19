From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 20/21] ntb_netdev: improve logging
Date: Sat, 19 Jan 2013 02:02:34 -0700
Message-ID: <1358586155-23322-21-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve driver logging to be more helpful

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/net/ntb_netdev.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ntb_netdev.c b/drivers/net/ntb_netdev.c
index 37173ce..02213a8 100644
--- a/drivers/net/ntb_netdev.c
+++ b/drivers/net/ntb_netdev.c
@@ -153,7 +153,7 @@ static netdev_tx_t ntb_netdev_start_xmit(struct sk_buff *skb,
 	struct ntb_netdev *dev = netdev_priv(ndev);
 	int rc;
 
-	netdev_dbg(ndev, "ntb_transport_tx_enqueue\n");
+	netdev_dbg(ndev, "%s: skb len %d\n", __func__, skb->len);
 
 	rc = ntb_transport_tx_enqueue(dev->qp, skb, skb->data, skb->len);
 	if (rc)
@@ -355,7 +355,7 @@ static int ntb_netdev_probe(struct pci_dev *pdev)
 		goto err1;
 
 	list_add(&dev->list, &dev_list);
-	pr_info("%s: %s created\n", KBUILD_MODNAME, ndev->name);
+	dev_info(&pdev->dev, "%s created\n", ndev->name);
 	return 0;
 
 err1:
@@ -408,6 +408,5 @@ static void __exit ntb_netdev_exit_module(void)
 {
 	ntb_unregister_client(&ntb_netdev_client);
 	ntb_unregister_client_dev(KBUILD_MODNAME);
-	pr_info("%s: Driver removed\n", KBUILD_MODNAME);
 }
 module_exit(ntb_netdev_exit_module);
-- 
1.7.9.5
