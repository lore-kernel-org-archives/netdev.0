From: David Miller <davem@davemloft.net>
Subject: [PATCH]: SELINUX fixup for netfilter hook changes
Date: Mon, 15 Oct 2007 02:59:09 -0700 (PDT)
Message-ID: <20071015.025909.77039408.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37093
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759388AbXJOJ7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:59:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E24EE2900F9
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 02:59:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I just noticed a warning for this in my allmodconfig build,
so I checked in the obvious fix.

commit d0a23b19f552c4fd0126d903078ea5ceca968617
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Oct 15 02:58:25 2007 -0700

    [SELINUX]: Update for netfilter ->hook() arg changes.
    
    They take a "struct sk_buff *" instead of a "struct sk_buff **" now.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 3c3fff3..cf76150 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3932,7 +3932,7 @@ out:
 }
 
 static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
-                                              struct sk_buff **pskb,
+                                              struct sk_buff *skb,
                                               const struct net_device *in,
                                               const struct net_device *out,
                                               int (*okfn)(struct sk_buff *),
@@ -3941,7 +3941,6 @@ static unsigned int selinux_ip_postroute_last(unsigned int hooknum,
 	char *addrp;
 	int len, err = 0;
 	struct sock *sk;
-	struct sk_buff *skb = *pskb;
 	struct avc_audit_data ad;
 	struct net_device *dev = (struct net_device *)out;
 	struct sk_security_struct *sksec;
@@ -3977,23 +3976,23 @@ out:
 }
 
 static unsigned int selinux_ipv4_postroute_last(unsigned int hooknum,
-						struct sk_buff **pskb,
+						struct sk_buff *skb,
 						const struct net_device *in,
 						const struct net_device *out,
 						int (*okfn)(struct sk_buff *))
 {
-	return selinux_ip_postroute_last(hooknum, pskb, in, out, okfn, PF_INET);
+	return selinux_ip_postroute_last(hooknum, skb, in, out, okfn, PF_INET);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
 static unsigned int selinux_ipv6_postroute_last(unsigned int hooknum,
-						struct sk_buff **pskb,
+						struct sk_buff *skb,
 						const struct net_device *in,
 						const struct net_device *out,
 						int (*okfn)(struct sk_buff *))
 {
-	return selinux_ip_postroute_last(hooknum, pskb, in, out, okfn, PF_INET6);
+	return selinux_ip_postroute_last(hooknum, skb, in, out, okfn, PF_INET6);
 }
 
 #endif	/* IPV6 */
