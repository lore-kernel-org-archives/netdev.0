From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6] jme: Fix compile warning introduced by new pm macro
Date: Tue, 28 Jun 2011 13:12:45 +0800
Message-ID: <1309237965-25102-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>, <stable@kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:51886 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856Ab1F1FMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 01:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

SIMPLE_DEV_PM_OPS is using SET_SYSTEM_SLEEP_PM_OPS
and SET_SYSTEM_SLEEP_PM_OPS is empty when CONFIG_PM_SLEEP
is not defined.

Switching #ifdef CONFIG_PM to #ifdef CONFIG_PM_SLEEP

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: stable@kernel.org
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

