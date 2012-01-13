From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 2/5] bcma: add stub for bcma_bus suspend()
Date: Fri, 13 Jan 2012 00:00:41 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201130000200.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:54305 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab2AMIAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:00:04 -0500
Received: by iabz25 with SMTP id z25so3984539iab.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 00:00:04 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jan 2012 22:50:31 -0800

.. and connect it up with the pci host bcma driver.

Now, the next step is to connect those bcma bus-level suspend/resume
functions to the actual bcma device suspend resume functions.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/bcma/bcma_private.h |    1 +
 drivers/bcma/host_pci.c     |    5 ++++-
 drivers/bcma/main.c         |    5 +++++
 3 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index fda56bde36b8..0def898a1d15 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -19,6 +19,7 @@ int __init bcma_bus_early_register(struct bcma_bus *bus,
 				   struct bcma_device *core_cc,
 				   struct bcma_device *core_mips);
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus);
 int bcma_bus_resume(struct bcma_bus *bus);
 #endif
 
diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 3aee641c9b7b..33ec3054248e 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -237,7 +237,10 @@ static void bcma_host_pci_remove(struct pci_dev *dev)
 #ifdef CONFIG_PM
 static int bcma_suspend(struct device *dev)
 {
-	return 0;
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct bcma_bus *bus = pci_get_drvdata(pdev);
+
+	return bcma_bus_suspend(bus);
 }
 
 static int bcma_resume(struct device *dev)
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 10f92b371e58..b711d9d634a7 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -241,6 +241,11 @@ int __init bcma_bus_early_register(struct bcma_bus *bus,
 }
 
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus)
+{
+	return 0;
+}
+
 int bcma_bus_resume(struct bcma_bus *bus)
 {
 	struct bcma_device *core;
-- 
1.7.8.rc2.3.g0911
