From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] be2net: fix non static symbol warnings
Date: Sun, 25 Sep 2016 15:40:36 +0000
Message-ID: <1474818036-18872-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34978 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938905AbcIYPkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 11:40:45 -0400
Received: by mail-pa0-f68.google.com with SMTP id zl8so901140pac.2
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2016 08:40:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warnings:

drivers/net/ethernet/emulex/benet/be_main.c:47:25: warning:
 symbol 'be_err_recovery_workq' was not declared. Should it be static?
drivers/net/ethernet/emulex/benet/be_main.c:63:25: warning:
 symbol 'be_wq' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9a94840..0d1ae3d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -44,7 +44,7 @@ MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 /* Per-module error detection/recovery workq shared across all functions.
  * Each function schedules its own work request on this shared workq.
  */
-struct workqueue_struct *be_err_recovery_workq;
+static struct workqueue_struct *be_err_recovery_workq;
 
 static const struct pci_device_id be_dev_ids[] = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
@@ -60,7 +60,7 @@ static const struct pci_device_id be_dev_ids[] = {
 MODULE_DEVICE_TABLE(pci, be_dev_ids);
 
 /* Workqueue used by all functions for defering cmd calls to the adapter */
-struct workqueue_struct *be_wq;
+static struct workqueue_struct *be_wq;
 
 /* UE Status Low CSR */
 static const char * const ue_status_low_desc[] = {
