From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 6/6] ctcm: replace sscanf by kstrto function
Date: Wed, 22 Oct 2014 12:18:07 +0200
Message-ID: <1413973087-18740-7-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:33128 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129AbaJVKSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 06:18:17 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:18:16 +0100
In-Reply-To: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Since a single integer value is read from the supplied buffer
use the kstrto functions instead of sscanf.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/ctcm_sysfs.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/ctcm_sysfs.c b/drivers/s390/net/ctcm_sysfs.c
index 6bcfbbb..47773c4 100644
--- a/drivers/s390/net/ctcm_sysfs.c
+++ b/drivers/s390/net/ctcm_sysfs.c
@@ -44,8 +44,8 @@ static ssize_t ctcm_buffer_write(struct device *dev,
 		return -ENODEV;
 	}
 
-	rc = sscanf(buf, "%u", &bs1);
-	if (rc != 1)
+	rc = kstrtouint(buf, 0, &bs1);
+	if (rc)
 		goto einval;
 	if (bs1 > CTCM_BUFSIZE_LIMIT)
 					goto einval;
@@ -151,8 +151,8 @@ static ssize_t ctcm_proto_store(struct device *dev,
 
 	if (!priv)
 		return -ENODEV;
-	rc = sscanf(buf, "%d", &value);
-	if ((rc != 1) ||
+	rc = kstrtoint(buf, 0, &value);
+	if (rc ||
 	    !((value == CTCM_PROTO_S390)  ||
 	      (value == CTCM_PROTO_LINUX) ||
 	      (value == CTCM_PROTO_MPC) ||
-- 
1.8.5.5
