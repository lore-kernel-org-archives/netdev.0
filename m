From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: can: replace strict_strtoul() with kstrtoul()
Date: Sat, 01 Jun 2013 16:18:55 +0900
Message-ID: <000d01ce5e98$46b6d430$d4247c90$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Wolfgang Grandegger' <wg@grandegger.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-language: ko
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/at91_can.c             |    2 +-
 drivers/net/can/janz-ican3.c           |    2 +-
 drivers/net/can/slcan.c                |    2 +-
 drivers/net/can/softing/softing_main.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 5566566..ce8421a 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1220,7 +1220,7 @@ static ssize_t at91_sysfs_set_mb0_id(struct device *dev,
 		goto out;
 	}
 
-	err = strict_strtoul(buf, 0, &can_id);
+	err = kstrtoul(buf, 0, &can_id);
 	if (err) {
 		ret = err;
 		goto out;
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index c4bc1d2..36bd6fa 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1734,7 +1734,7 @@ static ssize_t ican3_sysfs_set_term(struct device *dev,
 	unsigned long enable;
 	int ret;
 
-	if (strict_strtoul(buf, 0, &enable))
+	if (kstrtoul(buf, 0, &enable))
 		return -EINVAL;
 
 	ret = ican3_set_termination(mod, enable);
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 06b7e09..874188b 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -161,7 +161,7 @@ static void slc_bump(struct slcan *sl)
 
 	sl->rbuff[dlc_pos] = 0; /* terminate can_id string */
 
-	if (strict_strtoul(sl->rbuff+1, 16, &ultmp))
+	if (kstrtoul(sl->rbuff+1, 16, &ultmp))
 		return;
 
 	cf.can_id = ultmp;
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
index 3a2b456..65eef1e 100644
--- a/drivers/net/can/softing/softing_main.c
+++ b/drivers/net/can/softing/softing_main.c
@@ -594,7 +594,7 @@ static ssize_t store_output(struct device *dev, struct device_attribute *attr,
 	unsigned long val;
 	int ret;
 
-	ret = strict_strtoul(buf, 0, &val);
+	ret = kstrtoul(buf, 0, &val);
 	if (ret < 0)
 		return ret;
 	val &= 0xFF;
-- 
1.7.10.4


