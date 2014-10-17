From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: remove phy.h and phy_fixed.h inclusions
Date: Thu, 16 Oct 2014 17:55:55 -0700
Message-ID: <1413507355-28837-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:45622 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaJQA5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 20:57:19 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so4417730pad.25
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 17:57:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to include phy.h nor phy_fixed.h when we can use
forward declarations instead to keep the include chain smaller.

Doing this unveiled that we were implicitely getting the definitions for
struct ethtool_eee and struct ethtool_wolinfo, and that net/dsa/slave.c
was missing an include of phy_fixed.h.

Fixes: ec9436baedb6 ("net: dsa: allow drivers to do link adjustment")
Fixes: ce31b31c68e7 ("net: dsa: allow updating fixed PHY link information")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 7 +++++--
 net/dsa/slave.c   | 1 +
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58ad8c6492db..0c38b083e6eb 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -16,8 +16,11 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
-#include <linux/phy.h>
-#include <linux/phy_fixed.h>
+
+struct phy_device;
+struct fixed_phy_status;
+struct ethtool_eee;
+struct ethtool_wolinfo;
 
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8030489d9cbe..a851e9f14118 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -11,6 +11,7 @@
 #include <linux/list.h>
 #include <linux/etherdevice.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
 #include "dsa_priv.h"
-- 
1.9.1
