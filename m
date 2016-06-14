From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v3 6/7] vmxnet3: introduce command to register memory region
Date: Mon, 13 Jun 2016 18:50:06 -0700
Message-ID: <1465869007-10822-7-git-send-email-skhare@vmware.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Guolin Yang <gyang@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 274e145..c3a3164 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -81,6 +81,7 @@ enum {
 	VMXNET3_CMD_RESERVED2,
 	VMXNET3_CMD_RESERVED3,
 	VMXNET3_CMD_SET_COALESCE,
+	VMXNET3_CMD_REGISTER_MEMREGS,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
@@ -668,6 +669,22 @@ struct Vmxnet3_CoalesceScheme {
 	} coalPara;
 };
 
+struct Vmxnet3_MemoryRegion {
+	__le64					startPA;
+	__le32					length;
+	__le16					txQueueBits;
+	__le16					rxQueueBits;
+};
+
+#define MAX_MEMORY_REGION_PER_QUEUE 16
+#define MAX_MEMORY_REGION_PER_DEVICE 256
+
+struct Vmxnet3_MemRegs {
+	__le16					numRegs;
+	__le16					pad[3];
+	struct Vmxnet3_MemoryRegion		memRegs[1];
+};
+
 /* If the command data <= 16 bytes, use the shared memory directly.
  * otherwise, use variable length configuration descriptor.
  */
-- 
2.8.2
