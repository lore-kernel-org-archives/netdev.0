From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/3] qlge: bugfix: Add flash offset for second port.
Date: Mon,  2 Feb 2009 13:41:53 -0800
Message-ID: <1233610914-7448-2-git-send-email-ron.mercer@qlogic.com>
References: <1233610914-7448-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12624 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057AbZBBVnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:43:51 -0500
In-Reply-To: <1233610914-7448-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this the 2nd port gets first ports MAC addr.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 17d02eb..c6c0704 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -670,12 +670,19 @@ static int ql_get_flash_params(struct ql_adapter *qdev)
 	int i;
 	int status;
 	__le32 *p = (__le32 *)&qdev->flash;
+	u32 offset = 0;
+
+	/* Second function's parameters follow the first
+	 * function's.
+	 */
+	if (qdev->func)
+		offset = sizeof(qdev->flash) / sizeof(u32);
 
 	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
 		return -ETIMEDOUT;
 
 	for (i = 0; i < sizeof(qdev->flash) / sizeof(u32); i++, p++) {
-		status = ql_read_flash_word(qdev, i, p);
+		status = ql_read_flash_word(qdev, i+offset, p);
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
 			goto exit;
-- 
1.6.0.2

