From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] be2net: Delete an unnecessary check in two functions
Date: Fri, 1 Jan 2016 00:22:21 +0100
Message-ID: <5685B8AD.7010900@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sathya Perla <sathya.perla@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 00:11:57 +0100

Remove two checks for null pointers which would be handled by usual
error detection before.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index b63d8ad..ba98297 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -4366,9 +4366,7 @@ int be_cmd_get_profile_config(struct be_adapter *adapter,
 	if (vf_res)
 		res->vf_if_cap_flags = vf_res->cap_flags;
 err:
-	if (cmd.va)
-		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
-				  cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
@@ -4398,10 +4396,7 @@ static int be_cmd_set_profile_config(struct be_adapter *adapter, void *desc,
 	memcpy(req->desc, desc, size);
 
 	status = be_cmd_notify_wait(adapter, &wrb);
-
-	if (cmd.va)
-		dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va,
-				  cmd.dma);
+	dma_free_coherent(&adapter->pdev->dev, cmd.size, cmd.va, cmd.dma);
 	return status;
 }
 
-- 
2.6.3

