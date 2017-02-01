From: Dimitris Michailidis <dmichail@google.com>
Subject: [PATCH] net: fix ndo_features_check/ndo_fix_features comment ordering
Date: Tue, 31 Jan 2017 16:03:13 -0800
Message-ID: <20170201000313.11868-1-dmichail@google.com>
Cc: netdev@vger.kernel.org, Dimitris Michailidis <dmichail@google.com>
To: davem@davemloft.net, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35170 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdBAAOC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 19:14:02 -0500
Received: by mail-pg0-f43.google.com with SMTP id 194so103723797pgd.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 16:12:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cdba756f5803a2 ("net: move ndo_features_check() close to
ndo_start_xmit()") inadvertently moved the doc comment for
.ndo_fix_features instead of .ndo_features_check. Fix the comment
ordering.

Fixes: cdba756f5803a2 ("net: move ndo_features_check() close to ndo_start_xmit()")
Signed-off-by: Dimitris Michailidis <dmichail@google.com>
---
 include/linux/netdevice.h | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9bde9558b596..70ad0291d517 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -866,11 +866,15 @@ struct netdev_xdp {
  *	of useless work if you return NETDEV_TX_BUSY.
  *	Required; cannot be NULL.
  *
- * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
- *		netdev_features_t features);
- *	Adjusts the requested feature flags according to device-specific
- *	constraints, and returns the resulting flags. Must not modify
- *	the device state.
+ * netdev_features_t (*ndo_features_check)(struct sk_buff *skb,
+ *					   struct net_device *dev
+ *					   netdev_features_t features);
+ *	Called by core transmit path to determine if device is capable of
+ *	performing offload operations on a given packet. This is to give
+ *	the device an opportunity to implement any restrictions that cannot
+ *	be otherwise expressed by feature flags. The check is called with
+ *	the set of features that the stack has calculated and it returns
+ *	those the driver believes to be appropriate.
  *
  * u16 (*ndo_select_queue)(struct net_device *dev, struct sk_buff *skb,
  *                         void *accel_priv, select_queue_fallback_t fallback);
@@ -1028,6 +1032,12 @@ struct netdev_xdp {
  *	Called to release previously enslaved netdev.
  *
  *      Feature/offload setting functions.
+ * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
+ *		netdev_features_t features);
+ *	Adjusts the requested feature flags according to device-specific
+ *	constraints, and returns the resulting flags. Must not modify
+ *	the device state.
+ *
  * int (*ndo_set_features)(struct net_device *dev, netdev_features_t features);
  *	Called to update device configuration to new features. Passed
  *	feature set might be less than what was returned by ndo_fix_features()).
@@ -1100,15 +1110,6 @@ struct netdev_xdp {
  *	Callback to use for xmit over the accelerated station. This
  *	is used in place of ndo_start_xmit on accelerated net
  *	devices.
- * netdev_features_t (*ndo_features_check)(struct sk_buff *skb,
- *					   struct net_device *dev
- *					   netdev_features_t features);
- *	Called by core transmit path to determine if device is capable of
- *	performing offload operations on a given packet. This is to give
- *	the device an opportunity to implement any restrictions that cannot
- *	be otherwise expressed by feature flags. The check is called with
- *	the set of features that the stack has calculated and it returns
- *	those the driver believes to be appropriate.
  * int (*ndo_set_tx_maxrate)(struct net_device *dev,
  *			     int queue_index, u32 maxrate);
  *	Called when a user wants to set a max-rate limitation of specific
-- 
2.11.0.483.g087da7b7c-goog
