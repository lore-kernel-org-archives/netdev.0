From: akpm@linux-foundation.org
Subject: [patch 1/1] atlx: strncpy does not null terminate string
Date: Thu, 06 Aug 2009 16:06:56 -0700
Message-ID: <200908062306.n76N6ug6007294@imap1.linux-foundation.org>
Cc: csnook@redhat.com, jie.yang@atheros.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, roel.kluin@gmail.com
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57250 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755951AbZHFXH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:07:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

strlcpy() will always null terminate the string.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <csnook@redhat.com>
Cc: Jie Yang <jie.yang@atheros.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atl1c/atl1c_ethtool.c |    8 ++++----
 drivers/net/atlx/atl1.c           |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff -puN drivers/net/atl1c/atl1c_ethtool.c~atlx-strncpy-does-not-null-terminate-string drivers/net/atl1c/atl1c_ethtool.c
--- a/drivers/net/atl1c/atl1c_ethtool.c~atlx-strncpy-does-not-null-terminate-string
+++ a/drivers/net/atl1c/atl1c_ethtool.c
@@ -232,11 +232,11 @@ static void atl1c_get_drvinfo(struct net
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver,  atl1c_driver_name, sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, atl1c_driver_version,
+	strlcpy(drvinfo->driver,  atl1c_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, atl1c_driver_version,
 		sizeof(drvinfo->version));
-	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = 0;
 	drvinfo->testinfo_len = 0;
diff -puN drivers/net/atlx/atl1.c~atlx-strncpy-does-not-null-terminate-string drivers/net/atlx/atl1.c
--- a/drivers/net/atlx/atl1.c~atlx-strncpy-does-not-null-terminate-string
+++ a/drivers/net/atlx/atl1.c
@@ -3378,11 +3378,11 @@ static void atl1_get_drvinfo(struct net_
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver, ATLX_DRIVER_NAME, sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, ATLX_DRIVER_VERSION,
+	strlcpy(drvinfo->driver, ATLX_DRIVER_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, ATLX_DRIVER_VERSION,
 		sizeof(drvinfo->version));
-	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->eedump_len = ATL1_EEDUMP_LEN;
 }
_
