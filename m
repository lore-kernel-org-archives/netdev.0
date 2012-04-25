From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/15] batman-adv: add a new log level for DAT debugging
Date: Wed, 25 Apr 2012 15:26:58 +0200
Message-ID: <1335360431-30027-3-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38755 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab2DYN0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:16 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new log level has been added to concentrate messages regarding DAT: ARP
snooping, requests, response and DHT related messages.
The new log level is named DBG_DAT

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 Documentation/networking/batman-adv.txt |    3 ++-
 net/batman-adv/bat_sysfs.c              |    2 +-
 net/batman-adv/main.h                   |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/batman-adv.txt b/Documentation/networking/batman-adv.txt
index 220a58c..f804635 100644
--- a/Documentation/networking/batman-adv.txt
+++ b/Documentation/networking/batman-adv.txt
@@ -203,7 +203,8 @@ abled  during run time. Following log_levels are defined:
 2 - Enable messages related to route added / changed / deleted
 4 - Enable messages related to translation table operations
 8 - Enable messages related to bridge loop avoidance
-15 - enable all messages
+16 - Enable messaged related to DAT, ARP snooping and parsing
+31 - Enable all messages
 
 The debug output can be changed at runtime  using  the  file
 /sys/class/net/bat0/mesh/log_level. e.g.
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 2c81688..271c070 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -401,7 +401,7 @@ BAT_ATTR_UINT(gw_sel_class, S_IRUGO | S_IWUSR, 1, TQ_MAX_VALUE,
 static BAT_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, show_gw_bwidth,
 		store_gw_bwidth);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
+BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 31, NULL);
 #endif
 
 static struct bat_attribute *mesh_attrs[] = {
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d9832ac..a2b18d0 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -124,7 +124,8 @@ enum dbg_level {
 	DBG_ROUTES = 1 << 1, /* route added / changed / deleted */
 	DBG_TT	   = 1 << 2, /* translation table operations */
 	DBG_BLA    = 1 << 3, /* bridge loop avoidance */
-	DBG_ALL    = 15
+	DBG_DAT    = 1 << 4, /* snooped arp messages / dat operations */
+	DBG_ALL    = 31
 };
 
 /* Kernel headers */
-- 
1.7.9.4
