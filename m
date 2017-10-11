From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 3/7] net: qrtr: Add control packet definition to uapi
Date: Tue, 10 Oct 2017 23:45:19 -0700
Message-ID: <20171011064523.7902-4-bjorn.andersson@linaro.org>
References: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Chris Lew <clew@codeaurora.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011064523.7902-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The QMUX protocol specification defines structure of the special control
packet messages being sent between handlers of the control port.

Add these to the uapi header, as this structure and the associated types
are shared between the kernel and all userspace handlers of control
messages.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v1:
- None

 include/uapi/linux/qrtr.h | 32 ++++++++++++++++++++++++++++++++
 net/qrtr/qrtr.c           | 12 ------------
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/qrtr.h b/include/uapi/linux/qrtr.h
index 63e8803e4d90..179af64846e0 100644
--- a/include/uapi/linux/qrtr.h
+++ b/include/uapi/linux/qrtr.h
@@ -13,4 +13,36 @@ struct sockaddr_qrtr {
 	__u32 sq_port;
 };
 
+enum qrtr_pkt_type {
+	QRTR_TYPE_DATA		= 1,
+	QRTR_TYPE_HELLO		= 2,
+	QRTR_TYPE_BYE		= 3,
+	QRTR_TYPE_NEW_SERVER	= 4,
+	QRTR_TYPE_DEL_SERVER	= 5,
+	QRTR_TYPE_DEL_CLIENT	= 6,
+	QRTR_TYPE_RESUME_TX	= 7,
+	QRTR_TYPE_EXIT          = 8,
+	QRTR_TYPE_PING          = 9,
+	QRTR_TYPE_NEW_LOOKUP	= 10,
+	QRTR_TYPE_DEL_LOOKUP	= 11,
+};
+
+struct qrtr_ctrl_pkt {
+	__le32 cmd;
+
+	union {
+		struct {
+			__le32 service;
+			__le32 instance;
+			__le32 node;
+			__le32 port;
+		} server;
+
+		struct {
+			__le32 node;
+			__le32 port;
+		} client;
+	};
+} __packed;
+
 #endif /* _LINUX_QRTR_H */
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 15981abc042c..d85ca7170b8f 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -26,18 +26,6 @@
 #define QRTR_MIN_EPH_SOCKET 0x4000
 #define QRTR_MAX_EPH_SOCKET 0x7fff
 
-enum qrtr_pkt_type {
-	QRTR_TYPE_DATA		= 1,
-	QRTR_TYPE_HELLO		= 2,
-	QRTR_TYPE_BYE		= 3,
-	QRTR_TYPE_NEW_SERVER	= 4,
-	QRTR_TYPE_DEL_SERVER	= 5,
-	QRTR_TYPE_DEL_CLIENT	= 6,
-	QRTR_TYPE_RESUME_TX	= 7,
-	QRTR_TYPE_EXIT		= 8,
-	QRTR_TYPE_PING		= 9,
-};
-
 /**
  * struct qrtr_hdr - (I|R)PCrouter packet header
  * @version: protocol version
-- 
2.12.0
