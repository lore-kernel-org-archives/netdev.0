From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2] net: dsa: add includes for ethtool and phy_fixed definitions
Date: Fri, 17 Oct 2014 16:02:13 -0700
Message-ID: <1413586933-12090-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52584 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaJQXCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 19:02:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so1631235pab.40
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 16:02:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/dsa/slave.c uses functions and structures declared in phy_fixed.h
but does not explicitely include it, while dsa.h needs structure
declarations for 'struct ethtool_wolinfo' and 'struct ethtool_eee', fix
those by including the correct header files.

Fixes: ec9436baedb6 ("net: dsa: allow drivers to do link adjustment")
Fixes: ce31b31c68e7 ("net: dsa: allow updating fixed PHY link information")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- actually include the headers instead of using forward declarations

 include/net/dsa.h | 1 +
 net/dsa/slave.c   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58ad8c6492db..b76559293535 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -18,6 +18,7 @@
 #include <linux/of.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
+#include <linux/ethtool.h>
 
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
