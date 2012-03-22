From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: NETDEV_ALIGN should match L1_CACHE_BYTES
Date: Thu, 22 Mar 2012 15:19:20 -0700
Message-ID: <1332454760.6521.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55080 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957Ab2CVWTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 18:19:22 -0400
Received: by iagz16 with SMTP id z16so3699062iag.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 15:19:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

32 bytes alignment had a meaning 10 years ago, it is not anymore the
case.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

 include/linux/netdevice.h |    2 +-
 net/802/fc.c              |    2 +-
 net/802/fddi.c            |    2 +-
 net/802/hippi.c           |    2 +-
 net/802/tr.c              |    2 +-
 net/appletalk/dev.c       |    2 +-
 net/core/dev.c            |    4 ++--
 net/ethernet/eth.c        |    2 +-
 net/mac80211/main.c       |    2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8debe29..bbd1906 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1302,7 +1302,7 @@ struct net_device {
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
-#define	NETDEV_ALIGN		32
+#define	NETDEV_ALIGN		L1_CACHE_BYTES
 
 static inline
 int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
diff --git a/net/802/fc.c b/net/802/fc.c
index bd345f3..a7e0b87 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -122,7 +122,7 @@ static void fc_setup(struct net_device *dev)
  * Fill in the fields of the device structure with fibre channel-generic values.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size @sizeof_priv.  A cache line alignment is enforced for
  * this private data area.
  */
 struct net_device *alloc_fcdev(int sizeof_priv)
diff --git a/net/802/fddi.c b/net/802/fddi.c
index 94b3ad0..16cd2c3 100644
--- a/net/802/fddi.c
+++ b/net/802/fddi.c
@@ -203,7 +203,7 @@ static void fddi_setup(struct net_device *dev)
  * Fill in the fields of the device structure with FDDI-generic values.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size @sizeof_priv.  A cache line alignment is enforced for
  * this private data area.
  */
 struct net_device *alloc_fddidev(int sizeof_priv)
diff --git a/net/802/hippi.c b/net/802/hippi.c
index 91aca87..cdae3ed 100644
--- a/net/802/hippi.c
+++ b/net/802/hippi.c
@@ -223,7 +223,7 @@ static void hippi_setup(struct net_device *dev)
  * Fill in the fields of the device structure with HIPPI-generic values.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size @sizeof_priv.  A cache line alignment is enforced for
  * this private data area.
  */
 
diff --git a/net/802/tr.c b/net/802/tr.c
index 5e20cf8..ce6e6c9 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -625,7 +625,7 @@ static void tr_setup(struct net_device *dev)
  * Fill in the fields of the device structure with token ring-generic values.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size @sizeof_priv.  A cache line alignment is enforced for
  * this private data area.
  */
 struct net_device *alloc_trdev(int sizeof_priv)
diff --git a/net/appletalk/dev.c b/net/appletalk/dev.c
index 6c8016f..2b71a45 100644
--- a/net/appletalk/dev.c
+++ b/net/appletalk/dev.c
@@ -33,7 +33,7 @@ static void ltalk_setup(struct net_device *dev)
  * values. Basically does everything except registering the device.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size @sizeof_priv.  A cache line alignment is enforced for
  * this private data area.
  */
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 0f3eb7d..2e283fa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5935,11 +5935,11 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
-		/* ensure 32-byte alignment of private area */
+		/* ensure cache line alignment of private area */
 		alloc_size = ALIGN(alloc_size, NETDEV_ALIGN);
 		alloc_size += sizeof_priv;
 	}
-	/* ensure 32-byte alignment of whole construct */
+	/* ensure cache line alignment of whole construct */
 	alloc_size += NETDEV_ALIGN - 1;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index a93af86..4d4ec12 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -360,7 +360,7 @@ EXPORT_SYMBOL(ether_setup);
  * values. Basically does everything except registering the device.
  *
  * Constructs a new net device, complete with a private data area of
- * size (sizeof_priv).  A 32-byte (not bit) alignment is enforced for
+ * size (sizeof_priv).  A cache line alignment is enforced for
  * this private data area.
  */
 
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index b581a24..29c5b29 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -530,7 +530,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	if (WARN_ON(ops->sta_state && (ops->sta_add || ops->sta_remove)))
 		return NULL;
 
-	/* Ensure 32-byte alignment of our private data and hw private data.
+	/* Ensure cache line alignment of our private data and hw private data.
 	 * We use the wiphy priv data for both our ieee80211_local and for
 	 * the driver's private data
 	 *
