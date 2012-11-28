From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 6/6] qlcnic: fix coding style issues in qlcnic_minidump.c
Date: Wed, 28 Nov 2012 09:34:31 -0500
Message-ID: <1354113271-23850-7-git-send-email-sony.chacko@qlogic.com>
References: <1354113271-23850-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21993 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754538Ab2K1OxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 09:53:20 -0500
In-Reply-To: <1354113271-23850-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Fix coding style violations in qlcnic_minidump.c

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   34 ++++++++++----------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 5e22c62..12ff292 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -115,7 +115,7 @@ struct qlcnic_dump_entry {
 	} region;
 } __packed;
 
-enum op_codes {
+enum qlcnic_minidump_opcode {
 	QLCNIC_DUMP_NOP		= 0,
 	QLCNIC_DUMP_READ_CRB	= 1,
 	QLCNIC_DUMP_READ_MUX	= 2,
@@ -139,7 +139,7 @@ enum op_codes {
 };
 
 struct qlcnic_dump_operations {
-	enum op_codes opcode;
+	enum qlcnic_minidump_opcode opcode;
 	u32 (*handler)(struct qlcnic_adapter *, struct qlcnic_dump_entry *,
 		       __le32 *);
 };
@@ -269,7 +269,7 @@ static u32 qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 				break;
 			default:
 				dev_info(&adapter->pdev->dev,
-					"Unknown opcode\n");
+					 "Unknown opcode\n");
 				break;
 			}
 		}
@@ -455,8 +455,8 @@ static u32 qlcnic_read_memory(struct qlcnic_adapter *adapter,
 	/* check for data size of multiple of 16 and 16 byte alignment */
 	if ((addr & 0xf) || (reg_read%16)) {
 		dev_info(&adapter->pdev->dev,
-			"Unaligned memory addr:0x%x size:0x%x\n",
-			addr, reg_read);
+			 "Unaligned memory addr:0x%x size:0x%x\n",
+			 addr, reg_read);
 		return -EINVAL;
 	}
 
@@ -528,12 +528,12 @@ static const struct qlcnic_dump_operations fw_dump_ops[] = {
 /* Walk the template and collect dump for each entry in the dump template */
 static int
 qlcnic_valid_dump_entry(struct device *dev, struct qlcnic_dump_entry *entry,
-	u32 size)
+			u32 size)
 {
 	int ret = 1;
 	if (size != entry->hdr.cap_size) {
 		dev_info(dev,
-		"Invalidate dump, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
+			 "Invalid dump, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
 		entry->hdr.type, entry->hdr.mask, size, entry->hdr.cap_size);
 		dev_info(dev, "Aborting further dump capture\n");
 		ret = 0;
@@ -554,7 +554,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 
 	if (fw_dump->clr) {
 		dev_info(&adapter->pdev->dev,
-			"Previous dump not cleared, not capturing dump\n");
+			 "Previous dump not cleared, not capturing dump\n");
 		return -EIO;
 	}
 	/* Calculate the size for dump data area only */
@@ -567,8 +567,8 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	fw_dump->data = vzalloc(dump_size);
 	if (!fw_dump->data) {
 		dev_info(&adapter->pdev->dev,
-			"Unable to allocate (%d KB) for fw dump\n",
-			dump_size/1024);
+			 "Unable to allocate (%d KB) for fw dump\n",
+			 dump_size / 1024);
 		return -ENOMEM;
 	}
 	buffer = fw_dump->data;
@@ -595,14 +595,14 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		}
 		if (ops_index == ops_cnt) {
 			dev_info(&adapter->pdev->dev,
-				"Invalid entry type %d, exiting dump\n",
-				entry->hdr.type);
+				 "Invalid entry type %d, exiting dump\n",
+				 entry->hdr.type);
 			goto error;
 		}
 		/* Collect dump for this entry */
 		dump = fw_dump_ops[ops_index].handler(adapter, entry, buffer);
 		if (dump && !qlcnic_valid_dump_entry(&adapter->pdev->dev, entry,
-			dump))
+						     dump))
 			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
 		buf_offset += entry->hdr.cap_size;
 		entry_offset += entry->hdr.offset;
@@ -610,15 +610,15 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	}
 	if (dump_size != buf_offset) {
 		dev_info(&adapter->pdev->dev,
-			"Captured(%d) and expected size(%d) do not match\n",
-			buf_offset, dump_size);
+			 "Captured(%d) and expected size(%d) do not match\n",
+			 buf_offset, dump_size);
 		goto error;
 	} else {
 		fw_dump->clr = 1;
 		snprintf(mesg, sizeof(mesg), "FW_DUMP=%s",
-			adapter->netdev->name);
+			 adapter->netdev->name);
 		dev_info(&adapter->pdev->dev, "Dump data, %d bytes captured\n",
-			fw_dump->size);
+			 fw_dump->size);
 		/* Send a udev event to notify availability of FW dump */
 		kobject_uevent_env(&adapter->pdev->dev.kobj, KOBJ_CHANGE, msg);
 		return 0;
-- 
1.7.1
