From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 32/36] net: wireless: convert class code to use dev_groups
Date: Wed, 24 Jul 2013 15:05:35 -0700
Message-ID: <1374703539-9705-33-git-send-email-gregkh@linuxfoundation.org>
References: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev_attrs field of struct class is going away soon, dev_groups
should be used instead.  This converts the networking wireless class
code to use the correct field.

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

John, feel free to take this through your tree, or ACK it and I can take
it through mine.

 net/wireless/sysfs.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index a23253e0..9ee6bc1a 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -30,7 +30,8 @@ static ssize_t name ## _show(struct device *dev,			\
 			      char *buf)				\
 {									\
 	return sprintf(buf, fmt "\n", dev_to_rdev(dev)->member);	\
-}
+}									\
+static DEVICE_ATTR_RO(name)
 
 SHOW_FMT(index, "%d", wiphy_idx);
 SHOW_FMT(macaddress, "%pM", wiphy.perm_addr);
@@ -42,7 +43,7 @@ static ssize_t name_show(struct device *dev,
 	struct wiphy *wiphy = &dev_to_rdev(dev)->wiphy;
 	return sprintf(buf, "%s\n", dev_name(&wiphy->dev));
 }
-
+static DEVICE_ATTR_RO(name);
 
 static ssize_t addresses_show(struct device *dev,
 			      struct device_attribute *attr,
@@ -60,15 +61,17 @@ static ssize_t addresses_show(struct device *dev,
 
 	return buf - start;
 }
-
-static struct device_attribute ieee80211_dev_attrs[] = {
-	__ATTR_RO(index),
-	__ATTR_RO(macaddress),
-	__ATTR_RO(address_mask),
-	__ATTR_RO(addresses),
-	__ATTR_RO(name),
-	{}
+static DEVICE_ATTR_RO(addresses);
+
+static struct attribute *ieee80211_attrs[] = {
+	&dev_attr_index.attr,
+	&dev_attr_macaddress.attr,
+	&dev_attr_address_mask.attr,
+	&dev_attr_addresses.attr,
+	&dev_attr_name.attr,
+	NULL,
 };
+ATTRIBUTE_GROUPS(ieee80211);
 
 static void wiphy_dev_release(struct device *dev)
 {
@@ -146,7 +149,7 @@ struct class ieee80211_class = {
 	.name = "ieee80211",
 	.owner = THIS_MODULE,
 	.dev_release = wiphy_dev_release,
-	.dev_attrs = ieee80211_dev_attrs,
+	.dev_groups = ieee80211_groups,
 	.dev_uevent = wiphy_uevent,
 #ifdef CONFIG_PM
 	.suspend = wiphy_suspend,
-- 
1.8.3.rc0.20.gb99dd2e
