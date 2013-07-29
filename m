From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/6 net-next] cnic: Simplify cnic_release().
Date: Sun, 28 Jul 2013 19:03:56 -0700
Message-ID: <1375063440-4016-2-git-send-email-mchan@broadcom.com>
References: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4310 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050Ab3G2BmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 21:42:13 -0400
In-Reply-To: <1375063440-4016-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since unregister_netdevice_notifier() will replay the NETDEV_DOWN and
NETDEV_UNREGISTER_EVENTS, the cnic_dev_list will be cleaned up automatically.
The loop to cleanup the cnic_dev_list can be removed in cnic_release().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 764bfc1..c6822e1 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5693,21 +5693,8 @@ static struct notifier_block cnic_netdev_notifier = {
 
 static void cnic_release(void)
 {
-	struct cnic_dev *dev;
 	struct cnic_uio_dev *udev;
 
-	while (!list_empty(&cnic_dev_list)) {
-		dev = list_entry(cnic_dev_list.next, struct cnic_dev, list);
-		if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
-			cnic_ulp_stop(dev);
-			cnic_stop_hw(dev);
-		}
-
-		cnic_ulp_exit(dev);
-		cnic_unregister_netdev(dev);
-		list_del_init(&dev->list);
-		cnic_free_dev(dev);
-	}
 	while (!list_empty(&cnic_udev_list)) {
 		udev = list_entry(cnic_udev_list.next, struct cnic_uio_dev,
 				  list);
-- 
1.7.1
