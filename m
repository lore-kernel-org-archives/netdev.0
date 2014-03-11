From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: fix pmac_id[] allocation size
Date: Tue, 11 Mar 2014 18:53:06 +0530
Message-ID: <1394544189-20277-5-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:35590 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbaCKNUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:20:05 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>

The allocation size must be be_max_uc() and not "be_max_uc() + 1"
Signed-off-by: Ravikumar Nelavelli <ravikumar.nelavelli@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2f02bcb..eaf0891 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3314,9 +3314,8 @@ static int be_get_config(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	/* primary mac needs 1 pmac entry */
-	adapter->pmac_id = kcalloc(be_max_uc(adapter) + 1, sizeof(u32),
-				   GFP_KERNEL);
+	adapter->pmac_id = kcalloc(be_max_uc(adapter),
+				   sizeof(*adapter->pmac_id), GFP_KERNEL);
 	if (!adapter->pmac_id)
 		return -ENOMEM;
 
-- 
1.7.1
