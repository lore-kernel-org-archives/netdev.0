From: jamal <hadi@cyberus.ca>
Subject: Resend WAS(Re: cls patchlet
Date: 03 Oct 2004 16:12:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096834352.1046.349.camel@jzny.localdomain>
References: <1096833127.1048.333.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-B5wXIDjMz5cnfE0o4eEB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1096833127.1048.333.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-B5wXIDjMz5cnfE0o4eEB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ignore previous. This is better formated ;->

On Sun, 2004-10-03 at 15:52, jamal wrote:
> Dave,
> 
> resets class when tc_classid non-zero.
> 
> Please apply.
> 
> cheers,
> jamal

--=-B5wXIDjMz5cnfE0o4eEB
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
 
--- a/net/sched/cls_fw.c	2004/10/01 12:36:06	1.1
+++ b/net/sched/cls_fw.c	2004/10/01 14:22:30
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

--=-B5wXIDjMz5cnfE0o4eEB--
