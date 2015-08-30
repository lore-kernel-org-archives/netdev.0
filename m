From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/4] openvswitch: Remove vport-net
Date: Sat, 29 Aug 2015 17:44:08 -0700
Message-ID: <1440895448-16363-5-git-send-email-pshelar@nicira.com>
References: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:32898 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbbH3AoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 20:44:19 -0400
Received: by paczk9 with SMTP id zk9so4671371pac.0
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 17:44:19 -0700 (PDT)
In-Reply-To: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This structure is not used anymore.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.h |    2 --
 net/openvswitch/flow.c     |    3 ++-
 net/openvswitch/vport.h    |    4 ----
 3 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index da15fd3..c05b7d9 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -30,7 +30,6 @@
 #include "conntrack.h"
 #include "flow.h"
 #include "flow_table.h"
-#include "vport.h"
 
 #define DP_MAX_PORTS           USHRT_MAX
 #define DP_VPORT_HASH_BUCKETS  1024
@@ -134,7 +133,6 @@ struct dp_upcall_info {
 struct ovs_net {
 	struct list_head dps;
 	struct work_struct dp_notify_work;
-	struct vport_net vport_net;
 
 	/* Module reference for configuring conntrack. */
 	bool xt_label;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 5a3195e..5827784 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -46,10 +46,11 @@
 #include <net/mpls.h>
 #include <net/ndisc.h>
 
+#include "conntrack.h"
 #include "datapath.h"
 #include "flow.h"
 #include "flow_netlink.h"
-#include "conntrack.h"
+#include "vport.h"
 
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 30615ed..4b6f4a5 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -36,10 +36,6 @@ struct vport_parms;
 
 /* The following definitions are for users of the vport subsytem: */
 
-struct vport_net {
-	struct vport __rcu *gre_vport;
-};
-
 int ovs_vport_init(void);
 void ovs_vport_exit(void);
 
-- 
1.7.1
