From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: Fix warning in _hfcpci_softirq()
Date: Fri, 21 May 2010 20:33:49 -0400
Message-ID: <20100522002923.25277.39005.sendpatchset@prarit.bos.redhat.com>
Cc: Prarit Bhargava <prarit@redhat.com>
To: netdev@vger.kernel.org, isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932767Ab0EVAdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 20:33:54 -0400
Received: from int-mx03.intmail.prod.int.phx2.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4M0XpF7028035
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 May 2010 20:33:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix warning:

drivers/isdn/hardware/mISDN/hfcpci.c: In function `hfcpci_softirq':
drivers/isdn/hardware/mISDN/hfcpci.c:2321: warning: ignoring return value of `driver_for_each_device', declared with attribute warn_unused_result

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 5940a2c..12484d7 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2317,8 +2317,10 @@ _hfcpci_softirq(struct device *dev, void *arg)
 static void
 hfcpci_softirq(void *arg)
 {
-	(void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
-					_hfcpci_softirq);
+	int ret;
+
+	ret = driver_for_each_device(&hfc_driver.driver, NULL, arg,
+				     _hfcpci_softirq);
 
 	/* if next event would be in the past ... */
 	if ((s32)(hfc_jiffies + tics - jiffies) <= 0)
