From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] s390/qeth: use kstrtobool() in qeth_bridgeport_hostnotification_store()
Date: Wed,  4 Oct 2017 16:38:51 +0300
Message-ID: <20171004133851.18595-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-s390@vger.kernel.org, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:27994 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752008AbdJDNj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 09:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sysfs enabled value is a boolean, so kstrtobool() is a better fit
for parsing the input string since it does the range checking for us.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/s390/net/qeth_l2_sys.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 4608daedb204..470a4e5f3c62 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -146,18 +146,15 @@ static ssize_t qeth_bridgeport_hostnotification_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	int rc = 0;
-	int enable;
+	bool enable;
+	int rc;
 
 	if (!card)
 		return -EINVAL;
 
-	if (sysfs_streq(buf, "0"))
-		enable = 0;
-	else if (sysfs_streq(buf, "1"))
-		enable = 1;
-	else
-		return -EINVAL;
+	rc = kstrtobool(buf, &enable);
+	if (rc)
+		return rc;
 
 	mutex_lock(&card->conf_mutex);
 
-- 
2.14.2
