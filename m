From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: action stats double dip
Date: 25 Mar 2005 11:41:24 -0500
Message-ID: <1111768884.1092.533.camel@jzny.localdomain>
References: <1111767913.1091.530.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Vg4p5c2KjbVSYbtuug/j"
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1111767913.1091.530.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Vg4p5c2KjbVSYbtuug/j
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave, 
Ignore previous one - this one compiles better ;->


cheers,
jamal

On Fri, 2005-03-25 at 11:25, jamal wrote:
> Dave,
> 
> Following patch fixes a scenario where we have forward compatibility
> but action stats being double dipped. 
> 
> cheers,
> jamal
> 

--=-Vg4p5c2KjbVSYbtuug/j
Content-Disposition: attachment; filename=p_st3
Content-Type: text/plain; name=p_st3; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 26115-mod/net/sched/cls_route.c	2005/03/25 16:03:11	1.1
+++ 26115-mod/net/sched/cls_route.c	2005/03/25 16:34:02
@@ -599,8 +599,9 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
-		goto rtattr_failure;
+	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
+		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
+			goto rtattr_failure;
 
 	return skb->len;
 
--- 26115-mod/net/sched/cls_u32.c	2005/03/25 15:11:01	1.1
+++ 26115-mod/net/sched/cls_u32.c	2005/03/25 15:44:01
@@ -783,7 +783,7 @@
 	}
 
 	rta->rta_len = skb->tail - b;
-	if (TC_U32_KEY(n->handle))
+	if (TC_U32_KEY(n->handle) && n->exts.action && n->exts.action->type == TCA_OLD_COMPAT)
 		if (tcf_exts_dump_stats(skb, &n->exts, &u32_ext_map) < 0)
 			goto rtattr_failure;
 	return skb->len;
--- 26115-mod/net/sched/cls_tcindex.c	2005/03/25 16:04:46	1.1
+++ 26115-mod/net/sched/cls_tcindex.c	2005/03/25 16:36:47
@@ -496,8 +496,9 @@
 			goto rtattr_failure;
 		rta->rta_len = skb->tail-b;
 
-		if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
-			goto rtattr_failure;
+		if (r->exts.action && r->exts.action->type == TCA_OLD_COMPAT)
+			if (tcf_exts_dump_stats(skb, &r->exts, &tcindex_ext_map) < 0)
+				goto rtattr_failure;
 	}
 	
 	return skb->len;
--- 26115-mod/net/sched/cls_fw.c	2005/03/25 15:48:27	1.1
+++ 26115-mod/net/sched/cls_fw.c	2005/03/25 16:36:20
@@ -338,8 +338,9 @@
 
 	rta->rta_len = skb->tail - b;
 
-	if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
-		goto rtattr_failure;
+	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
+		if (tcf_exts_dump_stats(skb, &f->exts, &fw_ext_map) < 0)
+			goto rtattr_failure;
 
 	return skb->len;
 

--=-Vg4p5c2KjbVSYbtuug/j--
