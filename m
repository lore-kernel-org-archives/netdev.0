From: Jamal Hadi Salim <hadi@znyx.com>
Subject: patch: namsiz
Date: 16 Jan 2005 13:35:22 -0500
Message-ID: <1105900522.1090.798.camel@jzny.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Q5mGoHYx8/eygHatSK6h"
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Q5mGoHYx8/eygHatSK6h
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


heres one ive wanted to do for a while - dissociate action name size
from ifnamsiz. for now set it to namize, but later may change it.

cheers,
jamal

--=-Q5mGoHYx8/eygHatSK6h
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=bl_p
Content-Type: text/plain; name=bl_p; charset=ISO-8859-1

--- a/include/net/act_api.h	2005/01/16 13:23:00	1.1
+++ b/include/net/act_api.h	2005/01/16 13:24:13
@@ -40,6 +40,7 @@
 
 #define ACT_P_CREATED 1
 #define ACT_P_DELETED 1
+#define ANAMSIZ IFNAMSIZ
 
 struct tcf_act_hdr
 {
--- a/net/sched/act_api.c	2005/01/16 13:21:21	1.1
+++ b/net/sched/act_api.c	2005/01/16 13:24:33
@@ -227,7 +227,7 @@
 	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 
-	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
+	RTA_PUT(skb, TCA_KIND, ANAMSIZ, a->ops->kind);
 	if (tcf_action_copy_stats(skb, a))
 		goto rtattr_failure;
 	r = (struct rtattr*) skb->tail;
@@ -272,7 +272,7 @@
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
-	char act_name[IFNAMSIZ];
+	char act_name[ANAMSIZ];
 	struct rtattr *tb[TCA_ACT_MAX+1];
 	struct rtattr *kind;
 
@@ -284,10 +284,10 @@
 		kind = tb[TCA_ACT_KIND-1];
 		if (kind == NULL)
 			goto err_out;
-		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
+		if (rtattr_strlcpy(act_name, kind, ANAMSIZ) >= ANAMSIZ)
 			goto err_out;
 	} else {
-		if (strlcpy(act_name, name, IFNAMSIZ) >= IFNAMSIZ)
+		if (strlcpy(act_name, name, ANAMSIZ) >= ANAMSIZ)
 			goto err_out;
 	}
 

--=-Q5mGoHYx8/eygHatSK6h--
