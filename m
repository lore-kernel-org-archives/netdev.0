From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: don't change to 802.3ad mode while ARP monitor
 is running
Date: Fri, 15 Nov 2013 18:02:18 +0800
Message-ID: <5285F12A.6030307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:23000 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466Ab3KOKFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 05:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the ARP monitor is not support for 802.3ad, but We still
could change the mode to 802.3ad from ab mode while ARP monirot
is running, it is incorrect.

So add a check for 802.3ad in bonding_store_mode to fix the problem,
and make a micro program to simplify the code.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_options.c | 2 +-
 drivers/net/bonding/bonding.h      | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 9a5223c..abb4218 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -45,7 +45,7 @@ int bond_option_mode_set(struct bonding *bond, int mode)
 		return -EPERM;
 	}
 
-	if (BOND_MODE_IS_LB(mode) && bond->params.arp_interval) {
+	if (BOND_NO_USES_ARP(mode) && bond->params.arp_interval) {
 		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
 		       bond->dev->name, bond_mode_tbl[mode].modename);
 		return -EINVAL;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 046a605..e2c11cb 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -63,6 +63,10 @@
 		(((mode) == BOND_MODE_TLB) ||	\
 		 ((mode) == BOND_MODE_ALB))
 
+#define BOND_NO_USES_ARP(mode)				\
+		(((mode) == BOND_MODE_8023AD)	||	\
+		 ((mode) == BOND_MODE_TLB)	||	\
+		 ((mode) == BOND_MODE_ALB))
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
-- 
1.7.12
