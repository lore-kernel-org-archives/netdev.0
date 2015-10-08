From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx5_core: Improve mlx5 messages
Date: Thu,  8 Oct 2015 17:13:57 +0300
Message-ID: <1444313643-15284-2-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45222 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755467AbbJHOO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:28 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Improve the messages printed by the mlx5 macros to include the device
string. In addition, prefix names used by the macros with two underscores
to avoid possible name collisions.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 566a704..30c0be7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -43,25 +43,25 @@
 
 extern int mlx5_core_debug_mask;
 
-#define mlx5_core_dbg(dev, format, ...)					\
-	pr_debug("%s:%s:%d:(pid %d): " format,				\
-		 (dev)->priv.name, __func__, __LINE__, current->pid,	\
+#define mlx5_core_dbg(__dev, format, ...)				\
+	dev_dbg(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
+		 (__dev)->priv.name, __func__, __LINE__, current->pid,	\
 		 ##__VA_ARGS__)
 
-#define mlx5_core_dbg_mask(dev, mask, format, ...)			\
+#define mlx5_core_dbg_mask(__dev, mask, format, ...)			\
 do {									\
 	if ((mask) & mlx5_core_debug_mask)				\
-		mlx5_core_dbg(dev, format, ##__VA_ARGS__);		\
+		mlx5_core_dbg(__dev, format, ##__VA_ARGS__);		\
 } while (0)
 
-#define mlx5_core_err(dev, format, ...)					\
-	pr_err("%s:%s:%d:(pid %d): " format,				\
-	       (dev)->priv.name, __func__, __LINE__, current->pid,	\
+#define mlx5_core_err(__dev, format, ...)				\
+	dev_err(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
+	       (__dev)->priv.name, __func__, __LINE__, current->pid,	\
 	       ##__VA_ARGS__)
 
-#define mlx5_core_warn(dev, format, ...)				\
-	pr_warn("%s:%s:%d:(pid %d): " format,				\
-		(dev)->priv.name, __func__, __LINE__, current->pid,	\
+#define mlx5_core_warn(__dev, format, ...)				\
+	dev_warn(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
+		(__dev)->priv.name, __func__, __LINE__, current->pid,	\
 		##__VA_ARGS__)
 
 enum {
-- 
2.3.7
