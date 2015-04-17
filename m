From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Fri, 17 Apr 2015 15:12:25 -0400
Message-ID: <1429297945-26651-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit da4759c (sysfs: Use only return value from is_visible for
the file mode), it is possible to reduce the permissions of a file.

So declare temp1_max with the DEVICE_ATTR_RW macro and remove the write
permission in dsa_hwmon_attrs_visible if set_temp_limit isn't provided.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 5eaadab..079a224 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -124,7 +124,7 @@ static ssize_t temp1_max_store(struct device *dev,
 
 	return count;
 }
-static DEVICE_ATTR(temp1_max, S_IRUGO, temp1_max_show, temp1_max_store);
+static DEVICE_ATTR_RW(temp1_max);
 
 static ssize_t temp1_max_alarm_show(struct device *dev,
 				    struct device_attribute *attr, char *buf)
@@ -159,8 +159,8 @@ static umode_t dsa_hwmon_attrs_visible(struct kobject *kobj,
 	if (index == 1) {
 		if (!drv->get_temp_limit)
 			mode = 0;
-		else if (drv->set_temp_limit)
-			mode |= S_IWUSR;
+		else if (!drv->set_temp_limit)
+			mode &= ~S_IWUSR;
 	} else if (index == 2 && !drv->get_temp_alarm) {
 		mode = 0;
 	}
-- 
2.3.5
