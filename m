From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [ATM]: use clip_tbl instead of clp_tbl_hook (from Francois Romieu <romieu@fr.zoreil.com>)
Date: Mon, 23 Feb 2004 20:22:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402240122.i1O1M8g5028294@ginger.cmf.nrl.navy.mil>
References: <20040206231309.A26646@electric-eye.fr.zoreil.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, Francois Romieu <romieu@fr.zoreil.com>
In-reply-to: Your message of "Fri, 06 Feb 2004 23:13:09 +0100."
             <20040206231309.A26646@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1552  -> 1.1553 
#	      net/atm/clip.c	1.31    -> 1.32   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/23	chas@relax.cmf.nrl.navy.mil	1.1553
# [ATM]: use clip_tbl instead of clp_tbl_hook (from Francois Romieu <romieu@fr.zoreil.com>)
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Feb 23 20:11:20 2004
+++ b/net/atm/clip.c	Mon Feb 23 20:11:20 2004
@@ -899,7 +899,7 @@
 			if (v)
 				goto done;
   		}
-		state->n = clip_tbl_hook->hash_buckets[state->bucket + 1];
+		state->n = clip_tbl.hash_buckets[state->bucket + 1];
 	}
 done:
 	return v;
@@ -910,18 +910,12 @@
 	struct arp_state *state = seq->private;
 	void *ret = (void *)1;
 
-	if (!clip_tbl_hook) {
-		state->bucket = -1;
-		goto out;
-	}
-
-	read_lock_bh(&clip_tbl_hook->lock);
+	read_lock_bh(&clip_tbl.lock);
 	state->bucket = 0;
-	state->n = clip_tbl_hook->hash_buckets[0];
+	state->n = clip_tbl.hash_buckets[0];
 	state->vcc = (void *)1;
 	if (*pos)
 		ret = arp_get_idx(state, *pos);
-out:
 	return ret;
 }
 
@@ -930,7 +924,7 @@
 	struct arp_state *state = seq->private;
 
 	if (state->bucket != -1)
-		read_unlock_bh(&clip_tbl_hook->lock);
+		read_unlock_bh(&clip_tbl.lock);
 }
 
 static void *arp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
