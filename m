From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] ethtool: Use explicit designated initializers for .cmd
Date: Thu, 11 Feb 2010 12:12:06 -0800
Message-ID: <adatytn7crt.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:3519 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756846Ab0BKUMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 15:12:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize the .cmd member of various ethtool using a designated struct
initializer rather.  This makes things a teeny bit more robust, although
the chance of a struct layout changing is extremely remote, and also
makes the code a little easier to read.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Just something I noticed while browsing the code.  Doesn't change
generated code, and at least for me makes things slightly cleaner.

 net/core/ethtool.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8aee58..f1d5c6d 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -146,7 +146,7 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data)
 
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 	int err;
 
 	if (!dev->ethtool_ops->get_settings)
@@ -324,7 +324,7 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 
 static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
 {
-	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
+	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
 
 	if (!dev->ethtool_ops->get_wol)
 		return -EOPNOTSUPP;
@@ -458,7 +458,7 @@ static int ethtool_set_eeprom(struct net_device *dev, void __user *useraddr)
 
 static int ethtool_get_coalesce(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_coalesce coalesce = { ETHTOOL_GCOALESCE };
+	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
 
 	if (!dev->ethtool_ops->get_coalesce)
 		return -EOPNOTSUPP;
@@ -485,7 +485,7 @@ static int ethtool_set_coalesce(struct net_device *dev, void __user *useraddr)
 
 static int ethtool_get_ringparam(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_ringparam ringparam = { ETHTOOL_GRINGPARAM };
+	struct ethtool_ringparam ringparam = { .cmd = ETHTOOL_GRINGPARAM };
 
 	if (!dev->ethtool_ops->get_ringparam)
 		return -EOPNOTSUPP;
@@ -839,7 +839,7 @@ static int ethtool_get_perm_addr(struct net_device *dev, void __user *useraddr)
 static int ethtool_get_value(struct net_device *dev, char __user *useraddr,
 			     u32 cmd, u32 (*actor)(struct net_device *))
 {
-	struct ethtool_value edata = { cmd };
+	struct ethtool_value edata = { .cmd = cmd };
 
 	if (!actor)
 		return -EOPNOTSUPP;

-- 
Roland Dreier  <rolandd@cisco.com>
For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
