From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] DCB: fix kfree(skb)
Date: Fri, 02 Jan 2009 14:03:18 +0100
Message-ID: <495E1096.5060201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:32604 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957AbZABNDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 08:03:21 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1328562ika.5
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2009 05:03:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kfree_skb instead of kfree for struct sk_buff pointers.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5dbfe5f..8379496 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -191,7 +191,7 @@ static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
 	return 0;
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 	return ret;
 }
 
@@ -272,7 +272,7 @@ static int dcbnl_getpfccfg(struct net_device *netdev, struct nlattr **tb,
 	return 0;
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	return -EINVAL;
 }
@@ -314,7 +314,7 @@ static int dcbnl_getperm_hwaddr(struct net_device *netdev, struct nlattr **tb,
 
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	return -EINVAL;
 }
@@ -380,7 +380,7 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlattr **tb,
 	return 0;
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	return -EINVAL;
 }
@@ -458,7 +458,7 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlattr **tb,
 	return 0;
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	return ret;
 }
@@ -687,7 +687,7 @@ err_pg:
 	nla_nest_cancel(dcbnl_skb, pg_nest);
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	ret  = -EINVAL;
 	return ret;
@@ -949,7 +949,7 @@ err_bcn:
 	nla_nest_cancel(dcbnl_skb, bcn_nest);
 nlmsg_failure:
 err:
-	kfree(dcbnl_skb);
+	kfree_skb(dcbnl_skb);
 err_out:
 	ret  = -EINVAL;
 	return ret;
