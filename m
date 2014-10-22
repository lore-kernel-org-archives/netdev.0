From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 5/6] lcs: replace sscanf by kstrto function
Date: Wed, 22 Oct 2014 12:18:06 +0200
Message-ID: <1413973087-18740-6-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:38261 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109AbaJVKSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 06:18:16 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:18:15 +0100
In-Reply-To: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Since a single integer value is read from the supplied buffer
use the kstrto functions instead of sscanf.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/lcs.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 0a7d87c..92190aa 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1943,15 +1943,16 @@ static ssize_t
 lcs_portno_store (struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
 {
         struct lcs_card *card;
-	int value, rc;
+	int rc;
+	s16 value;
 
 	card = dev_get_drvdata(dev);
 
         if (!card)
                 return 0;
 
-	rc = sscanf(buf, "%d", &value);
-	if (rc != 1)
+	rc = kstrtos16(buf, 0, &value);
+	if (rc)
 		return -EINVAL;
         /* TODO: sanity checks */
         card->portno = value;
@@ -2007,8 +2008,8 @@ lcs_timeout_store (struct device *dev, struct device_attribute *attr, const char
         if (!card)
                 return 0;
 
-	rc = sscanf(buf, "%u", &value);
-	if (rc != 1)
+	rc = kstrtouint(buf, 0, &value);
+	if (rc)
 		return -EINVAL;
         /* TODO: sanity checks */
         card->lancmd_timeout = value;
-- 
1.8.5.5
