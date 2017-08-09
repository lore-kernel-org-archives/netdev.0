From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] atm: make atmdev_ops const
Date: Wed,  9 Aug 2017 14:49:15 +0530
Message-ID: <1502270355-4231-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, 3chas3@gmail.com,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these structures const as they are either passed to the function
atm_dev_register having the corresponding argument as const or stored in
the ops field of a atm_dev structure, which is also const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/atm/adummy.c    | 2 +-
 drivers/atm/atmtcp.c    | 2 +-
 drivers/atm/he.c        | 2 +-
 drivers/atm/idt77252.c  | 2 +-
 drivers/atm/nicstar.c   | 2 +-
 drivers/atm/solos-pci.c | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index da27ddf..8d98130 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -130,7 +130,7 @@ static ssize_t __show_signal(struct device *dev,
 	return 0;
 }
 
-static struct atmdev_ops adummy_ops =
+static const struct atmdev_ops adummy_ops =
 {
 	.open =		adummy_open,
 	.close =	adummy_close,	
diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
index 56fa16c..afebeb1 100644
--- a/drivers/atm/atmtcp.c
+++ b/drivers/atm/atmtcp.c
@@ -342,7 +342,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
  */
 
 
-static struct atmdev_ops atmtcp_c_dev_ops = {
+static const struct atmdev_ops atmtcp_c_dev_ops = {
 	.close		= atmtcp_c_close,
 	.send		= atmtcp_c_send
 };
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 8f6156d..e58538c 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -161,7 +161,7 @@
 	CLK_LOW
 };     
 
-static struct atmdev_ops he_ops =
+static const struct atmdev_ops he_ops =
 {
 	.open =		he_open,
 	.close =	he_close,	
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index b7a168c..47f3c4a 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -134,7 +134,7 @@ static int idt77252_proc_read(struct atm_dev *dev, loff_t * pos,
 static void idt77252_softint(struct work_struct *work);
 
 
-static struct atmdev_ops idt77252_ops =
+static const struct atmdev_ops idt77252_ops =
 {
 	.dev_close	= idt77252_dev_close,
 	.open		= idt77252_open,
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 9588d80..a970283 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -154,7 +154,7 @@ static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 
 static struct ns_dev *cards[NS_MAX_CARDS];
 static unsigned num_cards;
-static struct atmdev_ops atm_ops = {
+static const struct atmdev_ops atm_ops = {
 	.open = ns_open,
 	.close = ns_close,
 	.ioctl = ns_ioctl,
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 8754793..0df1a1c 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1187,7 +1187,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 	return 0;
 }
 
-static struct atmdev_ops fpga_ops = {
+static const struct atmdev_ops fpga_ops = {
 	.open =		popen,
 	.close =	pclose,
 	.ioctl =	NULL,
-- 
1.9.1
