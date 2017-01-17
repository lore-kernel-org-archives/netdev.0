From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [net, 3/6] net: korina: increase tx/rx ring sizes
Date: Tue, 17 Jan 2017 19:32:36 +0200
Message-ID: <1484674356-22363-1-git-send-email-roman@advem.lv>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34335 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdAQRku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:40:50 -0500
Received: by mail-lf0-f67.google.com with SMTP id q89so17266071lfi.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 09:40:49 -0800 (PST)
Received: from ubrain.lan ([213.175.92.61])
        by smtp.googlemail.com with ESMTPSA id 4sm2589175ljv.40.2017.01.17.09.32.39
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 09:32:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having larger ring sizes almost eliminates rx fifo overflow, thus improving performance.
This patch reduces rx overflow occurence by approximately 1000 times (from ~25k down to ~25 times per 3M frames)

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 45bd617..02f2364 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -80,8 +80,8 @@
 #define NAPI_WEIGHT	64
 
 /* the following must be powers of two */
-#define KORINA_NUM_RDS	64  /* number of receive descriptors */
-#define KORINA_NUM_TDS	64  /* number of transmit descriptors */
+#define KORINA_NUM_RDS	256 /* number of receive descriptors */
+#define KORINA_NUM_TDS	256 /* number of transmit descriptors */
 
 /* KORINA_RBSIZE is the hardware's default maximum receive
  * frame size in bytes. Having this hardcoded means that there
-- 
2.7.4
