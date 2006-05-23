From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/6] e1000: add shutdown handler back to fix WOL
Date: Tue, 23 May 2006 14:08:40 -0700
Message-ID: <20060523210840.18540.5075.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:57093 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932233AbWEWVDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:41 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Someone was waaay too aggressive and removed e1000's reboot notifier
instead of porting it to the new way of the shutdown handler.  This change
broke wake on lan.  Add the shutdown handler back in using the same method
as e100 uses.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index fb8cef6..df819c1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -221,6 +221,7 @@ static void e1000_restore_vlan(struct e1
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 static int e1000_resume(struct pci_dev *pdev);
 #endif
+static void e1000_shutdown(struct pci_dev *pdev);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /* for netdump / net console */
@@ -236,8 +237,9 @@ static struct pci_driver e1000_driver = 
 	/* Power Managment Hooks */
 #ifdef CONFIG_PM
 	.suspend  = e1000_suspend,
-	.resume   = e1000_resume
+	.resume   = e1000_resume,
 #endif
+	.shutdown = e1000_shutdown
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -4605,6 +4607,12 @@ e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
 #endif
+
+static void e1000_shutdown(struct pci_dev *pdev)
+{
+	e1000_suspend(pdev, PMSG_SUSPEND);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs



--
Auke Kok <auke-jan.h.kok@intel.com>
