From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 06/11] openvswitch: check CONFIG_OPENVSWITCH_GRE in makefile
Date: Tue, 27 Aug 2013 13:20:43 -0700
Message-ID: <1377634848-34327-7-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Cong Wang <amwang@redhat.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:60382 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753689Ab3H0UVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:10 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so5267348pbc.23
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:09 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Jesse Gross <jesse@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/Makefile    | 5 ++++-
 net/openvswitch/vport-gre.c | 3 ---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 82e4ee5..ea36e99 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -10,10 +10,13 @@ openvswitch-y := \
 	dp_notify.o \
 	flow.o \
 	vport.o \
-	vport-gre.o \
 	vport-internal_dev.o \
 	vport-netdev.o
 
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
 openvswitch-y += vport-vxlan.o
 endif
+
+ifneq ($(CONFIG_OPENVSWITCH_GRE),)
+openvswitch-y += vport-gre.o
+endif
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 493e977..21d5073 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -16,7 +16,6 @@
  * 02110-1301, USA
  */
 
-#ifdef CONFIG_OPENVSWITCH_GRE
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/if.h>
@@ -271,5 +270,3 @@ const struct vport_ops ovs_gre_vport_ops = {
 	.get_name	= gre_get_name,
 	.send		= gre_tnl_send,
 };
-
-#endif /* OPENVSWITCH_GRE */
-- 
1.8.1.2
