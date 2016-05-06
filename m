From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v4 1/2] soc: qcom: smd: Introduce compile stubs
Date: Fri,  6 May 2016 07:09:07 -0700
Message-ID: <1462543748-29187-1-git-send-email-bjorn.andersson@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, Courtney Cavin <ccavin@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andy Gross <andy.gross@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce compile stubs for the SMD API, allowing consumers to be
compile tested.

Acked-by: Andy Gross <andy.gross@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v3:
- None

Changes since v2:
- Introduce this patch, to allow compile testing of QRTR_SMD

 include/linux/soc/qcom/smd.h | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/soc/qcom/smd.h b/include/linux/soc/qcom/smd.h
index d0cb6d189a0a..46a984f5e3a3 100644
--- a/include/linux/soc/qcom/smd.h
+++ b/include/linux/soc/qcom/smd.h
@@ -45,13 +45,39 @@ struct qcom_smd_driver {
 	int (*callback)(struct qcom_smd_device *, const void *, size_t);
 };
 
+#if IS_ENABLED(CONFIG_QCOM_SMD)
+
 int qcom_smd_driver_register(struct qcom_smd_driver *drv);
 void qcom_smd_driver_unregister(struct qcom_smd_driver *drv);
 
+int qcom_smd_send(struct qcom_smd_channel *channel, const void *data, int len);
+
+#else
+
+static inline int qcom_smd_driver_register(struct qcom_smd_driver *drv)
+{
+	return -ENXIO;
+}
+
+static inline void qcom_smd_driver_unregister(struct qcom_smd_driver *drv)
+{
+	/* This shouldn't be possible */
+	WARN_ON(1);
+}
+
+static inline int qcom_smd_send(struct qcom_smd_channel *channel,
+				const void *data, int len)
+{
+	/* This shouldn't be possible */
+	WARN_ON(1);
+	return -ENXIO;
+}
+
+#endif
+
 #define module_qcom_smd_driver(__smd_driver) \
 	module_driver(__smd_driver, qcom_smd_driver_register, \
 		      qcom_smd_driver_unregister)
 
-int qcom_smd_send(struct qcom_smd_channel *channel, const void *data, int len);
 
 #endif
-- 
2.5.0
