From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 1/2] openvswitch: Allow GRE ports when compiled as a module.
Date: Fri, 21 Jun 2013 16:17:10 -0700
Message-ID: <1371856631-47807-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:51358 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1946207Ab3FUXRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 19:17:18 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl14so8483417pab.34
        for <netdev@vger.kernel.org>; Fri, 21 Jun 2013 16:17:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Open vSwitch GRE tunnels are currently only enabled if the GRE
datapath code is statically compiled in but it should be possible
to use it as a module as well.

CC: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-gre.c | 2 +-
 net/openvswitch/vport.c     | 2 +-
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
1.8.1.2
