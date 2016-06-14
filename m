From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v4 2/7] vmxnet3: introduce generic command interface to configure the device
Date: Tue, 14 Jun 2016 11:52:23 -0700
Message-ID: <1465930348-92164-3-git-send-email-skhare@vmware.com>
References: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Guolin Yang <gyang@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ex13-edg-ou-001.vmware.com ([208.91.0.189]:53844 "EHLO
	EX13-EDG-OU-001.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932125AbcFNSwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 14:52:34 -0400
In-Reply-To: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Guolin Yang <gyang@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index 8345e0c..a26a69d 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -79,6 +79,7 @@ enum {
 	VMXNET3_CMD_RESERVED1,
 	VMXNET3_CMD_LOAD_PLUGIN,
 	VMXNET3_CMD_RESERVED2,
+	VMXNET3_CMD_RESERVED3,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
@@ -612,6 +613,18 @@ struct Vmxnet3_RxQueueDesc {
 	u8				      __pad[88]; /* 128 aligned */
 };
 
+struct Vmxnet3_SetPolling {
+	u8					enablePolling;
+};
+
+/* If the command data <= 16 bytes, use the shared memory directly.
+ * otherwise, use variable length configuration descriptor.
+ */
+union Vmxnet3_CmdInfo {
+	struct Vmxnet3_VariableLenConfDesc	varConf;
+	struct Vmxnet3_SetPolling		setPolling;
+	__le64					data[2];
+};
 
 struct Vmxnet3_DSDevRead {
 	/* read-only region for device, read by dev in response to a SET cmd */
@@ -630,7 +643,14 @@ struct Vmxnet3_DriverShared {
 	__le32				pad;
 	struct Vmxnet3_DSDevRead	devRead;
 	__le32				ecr;
-	__le32				reserved[5];
+	__le32				reserved;
+	union {
+		__le32			reserved1[4];
+		union Vmxnet3_CmdInfo	cmdInfo; /* only valid in the context of
+						  * executing the relevant
+						  * command
+						  */
+	} cu;
 };
 
 
-- 
2.8.2
