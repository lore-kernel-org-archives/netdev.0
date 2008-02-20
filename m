From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH] Add PCI_DEVICE_TABLE macro
Date: Wed, 20 Feb 2008 13:53:37 +0100
Message-ID: <1203512031-14318-2-git-send-email-jonas@southpole.se>
References: <1203512031-14318-1-git-send-email-jonas@southpole.se>
Cc: greg@kroah.com, Jonas Bonn <jonas@southpole.se>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:42373 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756806AbYBTMxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 07:53:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id 6C0394ED10F
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 13:53:52 +0100 (CET)
In-Reply-To: <1203512031-14318-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The definitions of struct pci_device_id arrays should generally follow
the same pattern across the entire kernel.  This macro defines this
array as const and puts it into the __devinitconst section.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 include/linux/pci.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 87195b6..c7a91b1 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -389,6 +389,15 @@ struct pci_driver {
 #define	to_pci_driver(drv) container_of(drv, struct pci_driver, driver)
 
 /**
+ * PCI_DEVICE_TABLE - macro used to describe a pci device table
+ * @_table: device table name
+ *
+ * This macro is used to create a struct pci_device_id array (a device table) 
+ * in a generic manner.
+ */
+#define PCI_DEVICE_TABLE(_table) const struct pci_device_id _table[] __devinitconst
+
+/**
  * PCI_DEVICE - macro used to describe a specific pci device
  * @vend: the 16 bit PCI Vendor ID
  * @dev: the 16 bit PCI Device ID
-- 
1.5.3.8


