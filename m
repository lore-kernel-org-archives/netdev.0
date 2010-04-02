From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 8/9] qlcnic: fix endianness in fw validation
Date: Thu,  1 Apr 2010 22:01:35 -0700
Message-ID: <1270184496-18985-9-git-send-email-amit.salecha@qlogic.com>
References: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55862 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755145Ab0DBFBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 01:01:40 -0400
In-Reply-To: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpu_to_le32 was missing and used improperly.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index ccd24f4..89c64e8 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -627,7 +627,7 @@ qlcnic_validate_bootld(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 
 	tab_size = cpu_to_le32(tab_desc->findex) +
-			(cpu_to_le32(tab_desc->entry_size * (idx + 1)));
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
 
 	if (adapter->fw->size < tab_size)
 		return -EINVAL;
@@ -636,7 +636,7 @@ qlcnic_validate_bootld(struct qlcnic_adapter *adapter)
 		(cpu_to_le32(tab_desc->entry_size) * (idx));
 	descr = (struct uni_data_desc *)&unirom[offs];
 
-	data_size = descr->findex + cpu_to_le32(descr->size);
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
 
 	if (adapter->fw->size < data_size)
 		return -EINVAL;
@@ -662,7 +662,7 @@ qlcnic_validate_fw(struct qlcnic_adapter *adapter)
 		return -EINVAL;
 
 	tab_size = cpu_to_le32(tab_desc->findex) +
-			(cpu_to_le32(tab_desc->entry_size * (idx + 1)));
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
 
 	if (adapter->fw->size < tab_size)
 		return -EINVAL;
@@ -670,7 +670,7 @@ qlcnic_validate_fw(struct qlcnic_adapter *adapter)
 	offs = cpu_to_le32(tab_desc->findex) +
 		(cpu_to_le32(tab_desc->entry_size) * (idx));
 	descr = (struct uni_data_desc *)&unirom[offs];
-	data_size = descr->findex + cpu_to_le32(descr->size);
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
 
 	if (adapter->fw->size < data_size)
 		return -EINVAL;
-- 
1.6.0.2

