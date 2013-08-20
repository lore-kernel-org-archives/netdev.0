From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] openvswitch: check CONFIG_OPENVSWITCH_GRE in makefile
Date: Tue, 20 Aug 2013 17:20:10 +0800
Message-ID: <1376990410-21778-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab3HTJVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 05:21:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Jesse Gross <jesse@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 82e4ee5..4de6dcc 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -10,10 +10,12 @@ openvswitch-y := \
 	dp_notify.o \
 	flow.o \
 	vport.o \
-	vport-gre.o \
 	vport-internal_dev.o \
 	vport-netdev.o
 
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
 openvswitch-y += vport-vxlan.o
 endif
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
