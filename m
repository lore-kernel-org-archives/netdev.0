From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: minor cleanup for vcc_hash conversion
Date: Thu, 16 Oct 2003 07:25:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310161125.h9GBPVkT010703@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 --thanks

the original patch i sent printed the bucket index but 
normal users shouldnt be bothered with this.  further, i
let an used variable in fore200e.c after conversion.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1437  -> 1.1438 
#	      net/atm/proc.c	1.35    -> 1.36   
#	drivers/atm/fore200e.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/09	chas@relax.cmf.nrl.navy.mil	1.1438
# [ATM]: minor cleanup for vcc_hash conversion
# --------------------------------------------
#
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Wed Oct 15 14:50:27 2003
+++ b/drivers/atm/fore200e.c	Wed Oct 15 14:50:27 2003
@@ -1071,7 +1071,6 @@
     struct sock *s;
     struct atm_vcc* vcc;
     struct hlist_node *node;
-    int i;
 
     read_lock(&vcc_sklist_lock);
 
diff -Nru a/net/atm/proc.c b/net/atm/proc.c
--- a/net/atm/proc.c	Wed Oct 15 14:50:27 2003
+++ b/net/atm/proc.c	Wed Oct 15 14:50:27 2003
@@ -219,10 +219,10 @@
 		default:
 			seq_printf(seq, "%3d", vcc->sk->sk_family);
 	}
-	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d] 0x%x\n", vcc->flags, vcc->sk->sk_err,
+	seq_printf(seq, " %04lx  %5d %7d/%7d %7d/%7d [%d]\n", vcc->flags, vcc->sk->sk_err,
 		atomic_read(&vcc->sk->sk_wmem_alloc),vcc->sk->sk_sndbuf,
 		atomic_read(&vcc->sk->sk_rmem_alloc),vcc->sk->sk_rcvbuf,
-		atomic_read(&vcc->sk->sk_refcnt), vcc->sk->sk_hashent);
+		atomic_read(&vcc->sk->sk_refcnt));
 }
 
 static void svc_info(struct seq_file *seq, struct atm_vcc *vcc)
@@ -320,7 +320,7 @@
  	if (v == (void *)1) {
  		seq_printf(seq, sizeof(void *) == 4 ? "%-8s%s" : "%-16s%s",
  			"Address ", "Itf VPI VCI   Fam Flags Reply "
- 			"Send buffer     Recv buffer\n");
+ 			"Send buffer     Recv buffer      [refcnt]\n");
  	} else {
  		struct vcc_state *state = seq->private;
  		struct atm_vcc *vcc = atm_sk(state->sk);
