From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 31/36] net: ieee802154: convert class code to use dev_groups
Date: Wed, 24 Jul 2013 15:05:34 -0700
Message-ID: <1374703539-9705-32-git-send-email-gregkh@linuxfoundation.org>
References: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374703539-9705-1-git-send-email-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev_attrs field of struct class is going away soon, dev_groups
should be used instead.  This converts the ieee802154 class code to use
the correct field.

Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

netdev@ maintainers, feel free to take this through your tree, or ACK it
and I can take it through mine.

 net/ieee802154/wpan-class.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 13571eae..ef56ab5b 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -36,7 +36,8 @@ static ssize_t name ## _show(struct device *dev,			\
 	ret = snprintf(buf, PAGE_SIZE, format_string "\n", args);	\
 	mutex_unlock(&phy->pib_lock);					\
 	return ret;							\
-}
+}									\
+static DEVICE_ATTR_RO(name);
 
 #define MASTER_SHOW(field, format_string)				\
 	MASTER_SHOW_COMPLEX(field, format_string, phy->field)
@@ -66,15 +67,17 @@ static ssize_t channels_supported_show(struct device *dev,
 	mutex_unlock(&phy->pib_lock);
 	return len;
 }
-
-static struct device_attribute pmib_attrs[] = {
-	__ATTR_RO(current_channel),
-	__ATTR_RO(current_page),
-	__ATTR_RO(channels_supported),
-	__ATTR_RO(transmit_power),
-	__ATTR_RO(cca_mode),
-	{},
+static DEVICE_ATTR_RO(channels_supported);
+
+static struct attribute *pmib_attrs[] = {
+	&dev_attr_current_channel.attr,
+	&dev_attr_current_page.attr,
+	&dev_attr_channels_supported.attr,
+	&dev_attr_transmit_power.attr,
+	&dev_attr_cca_mode.attr,
+	NULL,
 };
+ATTRIBUTE_GROUPS(pmib);
 
 static void wpan_phy_release(struct device *d)
 {
@@ -85,7 +88,7 @@ static void wpan_phy_release(struct device *d)
 static struct class wpan_phy_class = {
 	.name = "ieee802154",
 	.dev_release = wpan_phy_release,
-	.dev_attrs = pmib_attrs,
+	.dev_groups = pmib_groups,
 };
 
 static DEFINE_MUTEX(wpan_phy_mutex);
-- 
1.8.3.rc0.20.gb99dd2e
