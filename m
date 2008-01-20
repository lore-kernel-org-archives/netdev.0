From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 03/18]: Kill useless VLAN_NAME define
Date: Sun, 20 Jan 2008 18:11:21 +0100 (MET)
Message-ID: <20080120171121.7980.8986.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399AbYATRLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:22 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Kill useless VLAN_NAME define

The only user already includes __FUNCTION__ (vlan_proto_init) in the output,
which is enough to identify what the message is about.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 6fcdd6b0d244f103898c3a37be2a3f4fec50fbd8
tree 6554c7cab6fdf09ac27fa1c75c93f0c105e249bd
parent f12d203e024ce5e0c98a9e88f6fdf8517a665ce4
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:54 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:54 +0100

 include/linux/if_vlan.h |    2 --
 net/8021q/vlan.c        |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a1b0066..0325d6b 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -72,8 +72,6 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
-#define VLAN_NAME "vlan"
-
 /* if this changes, algorithm will have to be reworked because this
  * depends on completely exhausting the VLAN identifier space.  Thus
  * it gives constant time look-up, but in many cases it wastes memory.
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 032bf44..af25255 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -89,8 +89,8 @@ static int __init vlan_proto_init(void)
 	err = vlan_proc_init();
 	if (err < 0) {
 		printk(KERN_ERR
-		       "%s %s: can't create entry in proc filesystem!\n",
-		       __FUNCTION__, VLAN_NAME);
+		       "%s: can't create entry in proc filesystem!\n",
+		       __FUNCTION__);
 		return err;
 	}
 
