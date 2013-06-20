From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Use correct config guard.
Date: Thu, 20 Jun 2013 15:08:14 -0700
Message-ID: <1371766094-3901-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:60406 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758390Ab3FTWIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:08:19 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so6842912pab.3
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 15:08:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was introduced by commit aa310701e787087
(openvswitch: Add gre tunnel support.)

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-gre.c |    2 +-
 net/openvswitch/vport.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 3a8d190..943e5c4 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -16,7 +16,7 @@
  * 02110-1301, USA
  */
 
-#ifdef CONFIG_NET_IPGRE_DEMUX
+#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/if.h>
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index f52dfb9..ba81294 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -39,7 +39,7 @@ static const struct vport_ops *vport_ops_list[] = {
 	&ovs_netdev_vport_ops,
 	&ovs_internal_vport_ops,
 
-#ifdef CONFIG_NET_IPGRE_DEMUX
+#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
 	&ovs_gre_vport_ops,
 #endif
 };
-- 
1.7.1
