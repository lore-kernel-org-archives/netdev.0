From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 1/4]: cls_rsvp: fix tcf_exts fallout
Date: Wed, 19 Jan 2005 05:38:42 +0100
Message-ID: <41EDE452.8000007@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030207030206010306030600"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030207030206010306030600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------030207030206010306030600
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/19 02:49:12+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: cls_rsvp: fix tcf_exts fallout
#   
#   The continue is supposed to continue the outer loop, not break
#   out of the do { } while (0) loop. cls_route.c is also changed
#   in a similar way for clarity, although it behaved correctly.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_rsvp.h
#   2005/01/19 02:49:04+01:00 kaber@coreworks.de +8 -8
#   [PKT_SCHED]: cls_rsvp: fix tcf_exts fallout
#   
#   The continue is supposed to continue the outer loop, not break
#   out of the do { } while (0) loop. cls_route.c is also changed
#   in a similar way for clarity, although it behaved correctly.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_route.c
#   2005/01/19 02:49:04+01:00 kaber@coreworks.de +14 -14
#   [PKT_SCHED]: cls_rsvp: fix tcf_exts fallout
#   
#   The continue is supposed to continue the outer loop, not break
#   out of the do { } while (0) loop. cls_route.c is also changed
#   in a similar way for clarity, although it behaved correctly.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_route.c b/net/sched/cls_route.c
--- a/net/sched/cls_route.c	2005-01-19 05:29:45 +01:00
+++ b/net/sched/cls_route.c	2005-01-19 05:29:45 +01:00
@@ -125,20 +125,20 @@
 	return 32;
 }
 
-#define ROUTE4_APPLY_RESULT()						\
-	do {								\
-		*res = f->res;						\
-		if (tcf_exts_is_available(&f->exts)) {			\
-			int r = tcf_exts_exec(skb, &f->exts, res);	\
-			if (r < 0) {					\
-				dont_cache = 1;				\
-				continue;				\
-			}						\
-			return r;					\
-		} else if (!dont_cache)					\
-			route4_set_fastmap(head, id, iif, f);		\
-		return 0;						\
-	} while(0)
+#define ROUTE4_APPLY_RESULT()					\
+{								\
+	*res = f->res;						\
+	if (tcf_exts_is_available(&f->exts)) {			\
+		int r = tcf_exts_exec(skb, &f->exts, res);	\
+		if (r < 0) {					\
+			dont_cache = 1;				\
+			continue;				\
+		}						\
+		return r;					\
+	} else if (!dont_cache)					\
+		route4_set_fastmap(head, id, iif, f);		\
+	return 0;						\
+}
 
 static int route4_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			   struct tcf_result *res)
diff -Nru a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
--- a/net/sched/cls_rsvp.h	2005-01-19 05:29:44 +01:00
+++ b/net/sched/cls_rsvp.h	2005-01-19 05:29:45 +01:00
@@ -123,14 +123,14 @@
 	.action = TCA_RSVP_ACT
 };
 
-#define RSVP_APPLY_RESULT()					\
-	do {							\
-		int r = tcf_exts_exec(skb, &f->exts, res);	\
-		if (r < 0)					\
-			continue;				\
-		else if (r > 0)					\
-			return r;				\
-	} while(0)
+#define RSVP_APPLY_RESULT()				\
+{							\
+	int r = tcf_exts_exec(skb, &f->exts, res);	\
+	if (r < 0)					\
+		continue;				\
+	else if (r > 0)					\
+		return r;				\
+}
 	
 static int rsvp_classify(struct sk_buff *skb, struct tcf_proto *tp,
 			 struct tcf_result *res)

--------------030207030206010306030600--
