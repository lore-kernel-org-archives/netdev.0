From: xiaohui.xin@intel.com
Subject: [RFC PATCH v7 14/19] Add header file for mp device.
Date: Sat,  5 Jun 2010 18:14:53 +0800
Message-ID: <1275732899-5423-14-git-send-email-xiaohui.xin@intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-9-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-10-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-11-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-12-git-send-email-xiaohui.xin@intel.com>
 <1275732899-5423-13-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65455 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932846Ab0FEKHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 06:07:14 -0400
In-Reply-To: <1275732899-5423-13-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Xiaohui <xiaohui.xin@intel.com>

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
Signed-off-by: Zhao Yu <yzhao81new@gmail.com>
Reviewed-by: Jeff Dike <jdike@linux.intel.com>
---
 include/linux/mpassthru.h |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/mpassthru.h

diff --git a/include/linux/mpassthru.h b/include/linux/mpassthru.h
new file mode 100644
index 0000000..ba8f320
--- /dev/null
+++ b/include/linux/mpassthru.h
@@ -0,0 +1,25 @@
+#ifndef __MPASSTHRU_H
+#define __MPASSTHRU_H
+
+#include <linux/types.h>
+#include <linux/if_ether.h>
+
+/* ioctl defines */
+#define MPASSTHRU_BINDDEV      _IOW('M', 213, int)
+#define MPASSTHRU_UNBINDDEV    _IO('M', 214)
+
+#ifdef __KERNEL__
+#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
+struct socket *mp_get_socket(struct file *);
+#else
+#include <linux/err.h>
+#include <linux/errno.h>
+struct file;
+struct socket;
+static inline struct socket *mp_get_socket(struct file *f)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif /* CONFIG_MEDIATE_PASSTHRU */
+#endif /* __KERNEL__ */
+#endif /* __MPASSTHRU_H */
-- 
1.5.4.4

