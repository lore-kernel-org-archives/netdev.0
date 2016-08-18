From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e: Use list_move instead of list_del/list_add
Date: Thu, 18 Aug 2016 14:57:22 -0700
Message-ID: <1471557456-136741-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53731 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754068AbcHSAt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:49:58 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>

Using list_move() instead of list_del() + list_add().

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
-- 
2.7.4
