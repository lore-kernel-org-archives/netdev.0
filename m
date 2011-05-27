From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH v2] atm: expose ATM device index in sysfs
Date: Fri, 27 May 2011 09:51:54 -0500
Message-ID: <1306507915.22126.2.camel@dcbw.foobar.com>
References: <1306432057.3151.10.camel@dcbw.foobar.com>
	 <1306432509.2543.1.camel@edumazet-laptop>
	 <1306434959.3151.39.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>,
	David Woodhouse <dwmw2@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab1E0Ouy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 10:50:54 -0400
In-Reply-To: <1306434959.3151.39.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's currently exposed only through /proc which, besides requiring
screen-scraping, doesn't allow userspace to distinguish between two
identical ATM adapters with different ATM indexes.  The ATM device index
is required when using PPPoATM on a system with multiple ATM adapters.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---

diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index f7fa67c..f49da58 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -59,6 +59,14 @@ static ssize_t show_atmaddress(struct device *cdev,
 	return pos - buf;
 }
 
+static ssize_t show_atmindex(struct device *cdev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct atm_dev *adev = to_atm_dev(cdev);
+
+	return sprintf(buf, "%d\n", adev->number);
+}
+
 static ssize_t show_carrier(struct device *cdev,
 			    struct device_attribute *attr, char *buf)
 {
@@ -99,6 +107,7 @@ static ssize_t show_link_rate(struct device *cdev,
 
 static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
 static DEVICE_ATTR(atmaddress, S_IRUGO, show_atmaddress, NULL);
+static DEVICE_ATTR(atmindex, S_IRUGO, show_atmindex, NULL);
 static DEVICE_ATTR(carrier, S_IRUGO, show_carrier, NULL);
 static DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
 static DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
@@ -106,6 +115,7 @@ static DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
 static struct device_attribute *atm_attrs[] = {
 	&dev_attr_atmaddress,
 	&dev_attr_address,
+	&dev_attr_atmindex,
 	&dev_attr_carrier,
 	&dev_attr_type,
 	&dev_attr_link_rate,


