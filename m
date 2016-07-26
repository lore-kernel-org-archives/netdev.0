From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] i40e: Use list_move instead of list_del/list_add
Date: Tue, 26 Jul 2016 14:58:30 +0000
Message-ID: <1469545110-32553-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33733 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756637AbcGZO6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 10:58:39 -0400
Received: by mail-pa0-f67.google.com with SMTP id q2so115357pap.0
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 07:58:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using list_move() instead of list_del() + list_add().

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index e1370c5..e6b9263 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -662,8 +662,7 @@ static int i40e_client_release(struct i40e_client *client)
 				 client->name, pf->hw.pf_id);
 		}
 		/* delete the client instance from the list */
-		list_del(&cdev->list);
-		list_add(&cdev->list, &cdevs_tmp);
+		list_move(&cdev->list, &cdevs_tmp);
 		atomic_dec(&client->ref_cnt);
 		dev_info(&pf->pdev->dev, "Deleted client instance of Client %s\n",
 			 client->name);
