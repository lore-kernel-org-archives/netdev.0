From: jamal <hadi@cyberus.ca>
Subject: cls patchlet
Date: 03 Oct 2004 15:52:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096833127.1048.333.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-aleoHynQzGWpIePjXRde"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-aleoHynQzGWpIePjXRde
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,

resets class when tc_classid non-zero.

Please apply.

cheers,
jamal

--=-aleoHynQzGWpIePjXRde
Content-Disposition: attachment; filename=classfix_p
Content-Type: text/plain; name=classfix_p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/sched/cls_u32.c	2004-08-14 01:36:33.000000000 -0400
+++ b/net/sched/cls_u32.c	2004-10-01 08:29:48.000000000 -0400
@@ -178,6 +178,7 @@
 					int pol_res = tcf_action_exec(skb, n->action);
 					if (skb->tc_classid > 0) {
 						res->classid = skb->tc_classid;
+						res->class = 0;
 						skb->tc_classid = 0;
 					}
 
--- /usr/src/269-rc3-mod/net/sched/cls_fw.c	2004/10/01 12:36:06	1.1
+++ /usr/src/269-rc3-mod/net/sched/cls_fw.c	2004/10/01 14:22:30
@@ -103,6 +103,12 @@
 #endif
                                if (f->action) {
                                        int pol_res = tcf_action_exec(skb, f->action);
+					if (skb->tc_classid > 0) {
+						res->classid = skb->tc_classid;
+						res->class = 0;
+						skb->tc_classid = 0;
+					}
+
                                        if (pol_res >= 0)
                                                return pol_res;
                                } else

--=-aleoHynQzGWpIePjXRde--
