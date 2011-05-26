From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: can: convert to %pK for kptr_restrict support
Date: Thu, 26 May 2011 16:57:53 +0200
Message-ID: <4DDE6A71.3080406@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dan Rosenberg <drosenberg@vsecurity.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:9727 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581Ab1EZO5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 10:57:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As these pointers have been printed without using %p they were missed in the
big network kptr_restrict conversion patch %p -> %pK from Dan Rosenberg.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/proc.c b/net/can/proc.c
index f4265cc..0016f73 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -204,12 +204,11 @@ static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
 
 	hlist_for_each_entry_rcu(r, n, rx_list, list) {
 		char *fmt = (r->can_id & CAN_EFF_FLAG)?
-			"   %-5s  %08X  %08x  %08x  %08x  %8ld  %s\n" :
-			"   %-5s     %03X    %08x  %08lx  %08lx  %8ld  %s\n";
+			"   %-5s  %08x  %08x  %pK  %pK  %8ld  %s\n" :
+			"   %-5s     %03x    %08x  %pK  %pK  %8ld  %s\n";
 
 		seq_printf(m, fmt, DNAME(dev), r->can_id, r->mask,
-				(unsigned long)r->func, (unsigned long)r->data,
-				r->matches, r->ident);
+				r->func, r->data, r->matches, r->ident);
 	}
 }
 

