From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 52/62: reduce NF_HOOK by one argument
Date: Tue, 16 Feb 2010 15:56:30 +0100 (MET)
Message-ID: <20100216145628.2796.69042.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52099 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932765Ab0BPO4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:31 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 23f3733d440b918ccb7746718f77256334cf6176
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jun 5 17:31:46 2009 +0200

    netfilter: reduce NF_HOOK by one argument
    
    No changes in vmlinux filesize.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 78f33d2..2f22816 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -163,11 +163,8 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh,
-				 int cond)
+				 int (*okfn)(struct sk_buff *), int thresh)
 {
-	if (!cond)
-		return 1;
 #ifndef CONFIG_NETFILTER_DEBUG
 	if (list_empty(&nf_hooks[pf][hook]))
 		return 1;
@@ -179,7 +176,7 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, skb, indev, outdev, okfn, INT_MIN, 1);
+	return nf_hook_thresh(pf, hook, skb, indev, outdev, okfn, INT_MIN);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -206,13 +203,13 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
 ({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, thresh, 1)) == 1)\
+if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, thresh)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
 
 #define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
 ({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, INT_MIN, cond)) == 1)\
+if ((cond) || (__ret = nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, INT_MIN)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
 
@@ -328,8 +325,7 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh,
-				 int cond)
+				 int (*okfn)(struct sk_buff *), int thresh)
 {
 	return okfn(skb);
 }
