From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/1] NetXen: Fix to get the driver working after sparse changes
Date: Mon, 12 Feb 2007 04:33:38 -0800
Message-ID: <200702121233.l1CCXcZ7024013@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:20504 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750938AbXBLMdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 07:33:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

---
 netxen_nic.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e021a30..2807ef4 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -252,7 +252,7 @@ typedef u32 netxen_ctx_msg;
 #define netxen_set_msg_ctxid(config_word, val)	\
 	((config_word) &= ~(0x3ff<<18), (config_word) |= (val & 0x3ff) << 18)
 #define netxen_set_msg_opcode(config_word, val)	\
-	((config_word) &= ~(0xf<<24), (config_word) |= (val & 0xf) << 24)
+	((config_word) &= ~(0xf<<28), (config_word) |= (val & 0xf) << 28)
 
 struct netxen_rcv_context {
 	__le64 rcv_ring_addr;
@@ -303,14 +303,14 @@ struct netxen_ring_ctx {
 	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & 0x7f))
 #define netxen_set_cmd_desc_opcode(cmd_desc, val)	\
 	((cmd_desc)->flags_opcode &= ~cpu_to_le16(0x3f<<7), \
-	(cmd_desc)->flags_opcode |= cpu_to_le16((val) & (0x3f<<7)))
+	(cmd_desc)->flags_opcode |= cpu_to_le16(((val & 0x3f)<<7)))
 
 #define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
 	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
 	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
 #define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
-	((cmd_desc)->num_of_buffers_total_length &= cpu_to_le32(0xff), \
-	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 24))
+	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xffffff00), \
+	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
 
 #define netxen_get_cmd_desc_opcode(cmd_desc)	\
 	((le16_to_cpu((cmd_desc)->flags_opcode) >> 7) & 0x003F)
