From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2] vlan: change return type of vlan_proc_rem_dev
Date: Thu, 18 Feb 2016 02:29:30 +0000
Message-ID: <1455762570-12019-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:4519 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423366AbcBRC2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:28:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since function vlan_proc_rem_dev() will only return 0, it's better to
return void instead of int.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/8021q/vlanproc.c | 3 +--
 net/8021q/vlanproc.h | 4 ++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index ae63cf7..5f1446c 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -184,12 +184,11 @@ int vlan_proc_add_dev(struct net_device *vlandev)
 /*
  *	Delete directory entry for VLAN device.
  */
-int vlan_proc_rem_dev(struct net_device *vlandev)
+void vlan_proc_rem_dev(struct net_device *vlandev)
 {
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
 	proc_remove(vlan_dev_priv(vlandev)->dent);
 	vlan_dev_priv(vlandev)->dent = NULL;
-	return 0;
 }
 
 /****** Proc filesystem entry points ****************************************/
diff --git a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
index 063f60a..8838a2e 100644
--- a/net/8021q/vlanproc.h
+++ b/net/8021q/vlanproc.h
@@ -5,7 +5,7 @@
 struct net;
 
 int vlan_proc_init(struct net *net);
-int vlan_proc_rem_dev(struct net_device *vlandev);
+void vlan_proc_rem_dev(struct net_device *vlandev);
 int vlan_proc_add_dev(struct net_device *vlandev);
 void vlan_proc_cleanup(struct net *net);
 
@@ -14,7 +14,7 @@ void vlan_proc_cleanup(struct net *net);
 #define vlan_proc_init(net)	(0)
 #define vlan_proc_cleanup(net)	do {} while (0)
 #define vlan_proc_add_dev(dev)	({(void)(dev), 0; })
-#define vlan_proc_rem_dev(dev)	({(void)(dev), 0; })
+#define vlan_proc_rem_dev(dev)	do {} while (0)
 #endif
 
 #endif /* !(__BEN_VLAN_PROC_INC__) */
-- 
1.8.3.1
