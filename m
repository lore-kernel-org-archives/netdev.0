From: nkiesel@tbdnetworks.com (Norbert Kiesel)
Subject: [PATCH] net: drop duplicate assignment in request_sock
Date: Sun, 5 Mar 2006 15:45:43 -0800
Message-ID: <20060305234543.GA22550@defiant.tbdnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932239AbWCEXpy@vger.kernel.org>
To: acme@conectiva.com.br
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Norbert Kiesel <nkiesel@tbdnetworks.com>

Hi,

just noticed that request_sock.[ch] contain a useless assignment of
rskq_accept_head to itself.  I assume this is a typo and the 2nd one
was supposed to be _tail.  However, setting _tail to NULL is not
needed, so the patch below just drops the 2nd assignment.

Best,
  Norbert

Signed-Off-By: Norbert Kiesel <nkiesel@tbdnetworks.com>

---

diff -ru a/include/net/request_sock.h b/include/net/request_sock.h
--- a/include/net/request_sock.h	2005-10-28 15:44:45.000000000 -0700
+++ b/include/net/request_sock.h	2006-03-05 15:22:33.000000000 -0800
@@ -145,7 +145,7 @@
 {
 	struct request_sock *req = queue->rskq_accept_head;
 
-	queue->rskq_accept_head = queue->rskq_accept_head = NULL;
+	queue->rskq_accept_head = NULL;
 	return req;
 }
 
diff -ru a/net/core/request_sock.c b/net/core/request_sock.c
--- a/net/core/request_sock.c	2006-03-05 14:40:50.000000000 -0800
+++ b/net/core/request_sock.c	2006-03-05 15:23:11.000000000 -0800
@@ -51,7 +51,7 @@
 
 	get_random_bytes(&lopt->hash_rnd, sizeof(lopt->hash_rnd));
 	rwlock_init(&queue->syn_wait_lock);
-	queue->rskq_accept_head = queue->rskq_accept_head = NULL;
+	queue->rskq_accept_head = NULL;
 	lopt->nr_table_entries = nr_table_entries;
 
 	write_lock_bh(&queue->syn_wait_lock);
