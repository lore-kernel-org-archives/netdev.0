From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: [PATCH 2.6] TBF: do not oops when user tries to attach/show filter
Date: Tue, 25 May 2004 23:12:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405252312.37140.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

TBF does not allow attaching filters; implement dummy tcf_chain method to
avoid oopsing.

-- 
Dmitry


===================================================================


ChangeSet@1.1750, 2004-05-25 22:54:30-05:00, dtor_core@ameritech.net
  [NET_SCHED] Do not oops when user tries to attach a filter to a TBF qdisc.
              (TBF does not allow attaching filters as it has only one class,
              filter should be attached either to TBF's parent or to its child)


 sch_tbf.c |    6 ++++++
 1 files changed, 6 insertions(+)


===================================================================



diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	2004-05-25 22:57:37 -05:00
+++ b/net/sched/sch_tbf.c	2004-05-25 22:57:37 -05:00
@@ -495,6 +495,11 @@
 	}
 }
 
+static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
 static struct Qdisc_class_ops tbf_class_ops =
 {
 	.graft		=	tbf_graft,
@@ -504,6 +509,7 @@
 	.change		=	tbf_change_class,
 	.delete		=	tbf_delete,
 	.walk		=	tbf_walk,
+	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
 };
 
