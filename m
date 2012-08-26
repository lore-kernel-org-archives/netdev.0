From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 1/2] drivers/ieee802154/at86rf230: replace the code under _init and _exit by macro
Date: Sun, 26 Aug 2012 19:10:10 +0400
Message-ID: <1345993811-13803-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Devendra Naga <develkernel412222@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:65519 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab2HZPPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 11:15:52 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr14so2617479wib.1
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 08:15:52 -0700 (PDT)
In-Reply-To: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code under _init and _exit functions is similar to the code of
module_spi_driver macro, which is a wrapper to the module_driver macro,
so use it instead.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Devendra Naga <develkernel412222@gmail.com>
---
 drivers/ieee802154/at86rf230.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/ieee802154/at86rf230.c b/drivers/ieee802154/at86rf230.c
index 5d30940..ba753d8 100644
--- a/drivers/ieee802154/at86rf230.c
+++ b/drivers/ieee802154/at86rf230.c
@@ -952,17 +952,7 @@ static struct spi_driver at86rf230_driver = {
 	.resume     = at86rf230_resume,
 };
 
-static int __init at86rf230_init(void)
-{
-	return spi_register_driver(&at86rf230_driver);
-}
-module_init(at86rf230_init);
-
-static void __exit at86rf230_exit(void)
-{
-	spi_unregister_driver(&at86rf230_driver);
-}
-module_exit(at86rf230_exit);
+module_spi_driver(at86rf230_driver);
 
 MODULE_DESCRIPTION("AT86RF230 Transceiver Driver");
 MODULE_LICENSE("GPL v2");
-- 
1.7.2.3
