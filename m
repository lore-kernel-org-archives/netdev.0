From: jamal <hadi@cyberus.ca>
Subject: PATCH: action stats double dip
Date: 25 Mar 2005 11:25:13 -0500
Message-ID: <1111767913.1091.530.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-K3TDgNBIR6tQKy6fTART"
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-K3TDgNBIR6tQKy6fTART
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Dave,

Following patch fixes a scenario where we have forward compatibility
but action stats being double dipped. 

cheers,
jamal


--=-K3TDgNBIR6tQKy6fTART
Content-Disposition: attachment; filename=p_st2
Content-Type: text/plain; name=p_st2; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/sched/cls_u32.c	2005/03/25 15:11:01	1.1
+++ b/net/sched/cls_u32.c	2005/03/25 15:44:01
@@ -783,7 +783,7 @@
 	}
 
 	rta->rta_len = skb->tail - b;
-	if (TC_U32_KEY(n->handle))
+	if (TC_U32_KEY(n->handle) && n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
 		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
 			goto rtattr_failure;
 	return skb->len;
--- a/net/sched/cls_tcindex.c	2005/03/25 16:04:46	1.1
+++ b/net/sched/cls_tcindex.c	2005/03/25 16:05:20
@@ -496,8 +496,9 @@
 			goto rtattr_failure;
 		rta->rta_len = skb->tail-b;
 
-		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
-			goto rtattr_failure;
+		if (n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
+			if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
+				goto rtattr_failure;
 	}
 	
 	return skb->len;
--- a/net/sched/cls_fw.c	2005/03/25 15:48:27	1.1
+++ b/net/sched/cls_fw.c	2005/03/25 16:02:22
@@ -338,8 +338,9 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
-		goto rtattr_failure;
+	if (n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
+		if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
+			goto rtattr_failure;
 
 	return skb->len;
 
--- a/net/sched/cls_route.c	2005/03/25 16:03:11	1.1
+++ b/net/sched/cls_route.c	2005/03/25 16:04:34
@@ -599,8 +599,9 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
-		goto rtattr_failure;
+	if (n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
+		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
+			goto rtattr_failure;
 
 	return skb->len;
 

--=-K3TDgNBIR6tQKy6fTART--
