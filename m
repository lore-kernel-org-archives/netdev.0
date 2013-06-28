From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v2] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Fri, 28 Jun 2013 12:39:55 -0700
Message-ID: <1372448395-30095-1-git-send-email-pshelar@nicira.com>
Cc: rdunlap@infradead.org, bhutchings@solarflare.com,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:42861 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752501Ab3F1TkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 15:40:01 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so2828543pad.33
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 12:40:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Openvswitch uses function from NET_IPGRE_DEMUX module.
Add Kconfig dependency to fix following compilation errors:
http://marc.info/?l=linux-netdev&m=137244035226634

CC: Jesse Gross <jesse@nicira.com>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
Signed-off-by: Pravin Shelar <pshelar@nicira.com>
---
v1-v2:
- use select to resolve dependency.
---
 net/openvswitch/Kconfig     |    1 +
 net/openvswitch/vport-gre.c |    2 --
 net/openvswitch/vport.c     |    3 ---
 3 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 9fbc04a..deaa9bb 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -4,6 +4,7 @@
 
 config OPENVSWITCH
 	tristate "Open vSwitch"
+	select NET_IPGRE_DEMUX
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
 	  environments.  In addition to supporting a variety of features
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 943e5c4..21d5073 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -16,7 +16,6 @@
  * 02110-1301, USA
  */
 
-#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/if.h>
@@ -271,4 +270,3 @@ const struct vport_ops ovs_gre_vport_ops = {
 	.get_name	= gre_get_name,
 	.send		= gre_tnl_send,
 };
-#endif
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index ba81294..ba240a8 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -38,10 +38,7 @@
 static const struct vport_ops *vport_ops_list[] = {
 	&ovs_netdev_vport_ops,
 	&ovs_internal_vport_ops,
-
-#if IS_ENABLED(CONFIG_NET_IPGRE_DEMUX)
 	&ovs_gre_vport_ops,
-#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
-- 
1.7.1
