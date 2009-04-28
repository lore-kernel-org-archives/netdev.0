From: Li Yang <leoli@freescale.com>
Subject: [PATCH] rio: warn_unused_result warnings fix
Date: Tue, 28 Apr 2009 18:15:37 +0800
Message-ID: <1240913737-23773-5-git-send-email-leoli@freescale.com>
References: <2a27d3730904280316l7049bddbie914907b16ccfff6@mail.gmail.com>
 <1240913737-23773-1-git-send-email-leoli@freescale.com>
 <1240913737-23773-2-git-send-email-leoli@freescale.com>
 <1240913737-23773-3-git-send-email-leoli@freescale.com>
 <1240913737-23773-4-git-send-email-leoli@freescale.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: akpm@linux-foundation.org, galak@kernel.crashing.org,
	davem@davemloft.net, mporter@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:40620 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755807AbZD1KTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 06:19:24 -0400
In-Reply-To: <1240913737-23773-4-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

warning: ignoring return value of 'device_add', declared with attribute warn_unused_result
warning: ignoring return value of 'sysfs_create_bin_file', declared with attribute warn_unused_result

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/rapidio/rio-scan.c  |    5 ++++-
 drivers/rapidio/rio-sysfs.c |    6 ++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/rapidio/rio-scan.c b/drivers/rapidio/rio-scan.c
index 74d0bfa..9309e24 100644
--- a/drivers/rapidio/rio-scan.c
+++ b/drivers/rapidio/rio-scan.c
@@ -265,7 +265,10 @@ static void rio_route_set_ops(struct rio_dev *rdev)
  */
 static void __devinit rio_add_device(struct rio_dev *rdev)
 {
-	device_add(&rdev->dev);
+	int err;
+
+	err = device_add(&rdev->dev);
+	WARN_ON(err);
 
 	spin_lock(&rio_global_list_lock);
 	list_add_tail(&rdev->global_list, &rio_devices);
diff --git a/drivers/rapidio/rio-sysfs.c b/drivers/rapidio/rio-sysfs.c
index 97a147f..ba742e8 100644
--- a/drivers/rapidio/rio-sysfs.c
+++ b/drivers/rapidio/rio-sysfs.c
@@ -214,9 +214,11 @@ static struct bin_attribute rio_config_attr = {
  */
 int rio_create_sysfs_dev_files(struct rio_dev *rdev)
 {
-	sysfs_create_bin_file(&rdev->dev.kobj, &rio_config_attr);
+	int err = 0;
 
-	return 0;
+	err = sysfs_create_bin_file(&rdev->dev.kobj, &rio_config_attr);
+
+	return err;
 }
 
 /**
-- 
1.5.4

