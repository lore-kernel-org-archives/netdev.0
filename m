From: Kim Jones <kim-marie.jones@intel.com>
Subject: [PATCH net-next] ethtool: Declare netdev_rss_key as __read_mostly.
Date: Tue,  2 Feb 2016 03:51:16 +0000
Message-ID: <1454385076-31469-1-git-send-email-kim-marie.jones@intel.com>
Cc: Kim Jones <kim-marie.jones@intel.com>,
	Alan Carey <alan.carey@intel.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3875 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbcBBLCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 06:02:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_rss_key is written to once and thereafter is read by
drivers when they are initialising. The fact that it is mostly
read and not written to makes it a candidate for a __read_mostly
declaration.

Signed-off-by: Kim Jones <kim-marie.jones@intel.com>
Signed-off-by: Alan Carey <alan.carey@intel.com>
Acked-by: Rami Rosen <rami.rosen@intel.com>
---
 include/linux/netdevice.h | 2 +-
 net/core/ethtool.c        | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ac140d..ec184a2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3742,7 +3742,7 @@ void netdev_lower_state_changed(struct net_device *lower_dev,
 
 /* RSS keys are 40 or 52 bytes long */
 #define NETDEV_RSS_KEY_LEN 52
-extern u8 netdev_rss_key[NETDEV_RSS_KEY_LEN];
+extern u8 netdev_rss_key[NETDEV_RSS_KEY_LEN] __read_mostly;
 void netdev_rss_key_fill(void *buffer, size_t len);
 
 int dev_get_nest_level(struct net_device *dev,
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index daf0470..453c803 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -632,7 +632,7 @@ static int ethtool_copy_validate_indir(u32 *indir, void __user *useraddr,
 	return 0;
 }
 
-u8 netdev_rss_key[NETDEV_RSS_KEY_LEN];
+u8 netdev_rss_key[NETDEV_RSS_KEY_LEN] __read_mostly;
 
 void netdev_rss_key_fill(void *buffer, size_t len)
 {
-- 
2.1.0

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
