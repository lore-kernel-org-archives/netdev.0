From: akpm@osdl.org
Subject: [patch 6/9] NET/atm: handle sysfs errors
Date: Fri, 20 Oct 2006 14:43:16 -0700
Message-ID: <200610202143.k9KLhG0p003801@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63108 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992765AbWJTVoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:44:03 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/atm/atm_sysfs.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff -puN net/atm/atm_sysfs.c~net-atm-handle-sysfs-errors net/atm/atm_sysfs.c
--- a/net/atm/atm_sysfs.c~net-atm-handle-sysfs-errors
+++ a/net/atm/atm_sysfs.c
@@ -141,7 +141,7 @@ static struct class atm_class = {
 int atm_register_sysfs(struct atm_dev *adev)
 {
 	struct class_device *cdev = &adev->class_dev;
-	int i, err;
+	int i, j, err;
 
 	cdev->class = &atm_class;
 	class_set_devdata(cdev, adev);
@@ -151,10 +151,19 @@ int atm_register_sysfs(struct atm_dev *a
 	if (err < 0)
 		return err;
 
-	for (i = 0; atm_attrs[i]; i++)
-		class_device_create_file(cdev, atm_attrs[i]);
+	for (i = 0; atm_attrs[i]; i++) {
+		err = class_device_create_file(cdev, atm_attrs[i]);
+		if (err)
+			goto err_out;
+	}
 
 	return 0;
+
+err_out:
+	for (j = 0; j < i; j++)
+		class_device_remove_file(cdev, atm_attrs[j]);
+	class_device_del(cdev);
+	return err;
 }
 
 void atm_unregister_sysfs(struct atm_dev *adev)
_
