From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 1/2] jme: Fix compile warning introduced by new pm macro
Date: Tue, 28 Jun 2011 13:23:34 +0800
Message-ID: <1309238615-25590-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:42197 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755577Ab1F1FXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 01:23:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

SIMPLE_DEV_PM_OPS is using SET_SYSTEM_SLEEP_PM_OPS
and SET_SYSTEM_SLEEP_PM_OPS is empty when CONFIG_PM_SLEEP
is not defined.

Switching #ifdef CONFIG_PM to #ifdef CONFIG_PM_SLEEP

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index b5b174a..2ce9339 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -3135,7 +3135,7 @@ jme_shutdown(struct pci_dev *pdev)
 	pci_pme_active(pdev, true);
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int jme_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
-- 
1.7.3.4

