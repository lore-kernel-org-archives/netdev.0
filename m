From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipvs -- fix error's in list_for_each changes.
Date: Mon, 22 Sep 2003 11:22:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030922112204.225e1a98.shemminger@osdl.org>
References: <20030916141750.53bbb04e.shemminger@osdl.org>
	<Pine.LNX.4.44.0309210934460.1468-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wensong Zhang <wensong@linux-vs.org>, <lvs-users@LinuxVirtualServer.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0309210934460.1468-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The earlier list_for_each changes introduced a couple of bugs where
lines got dropped.  This restores them.

diff -Nru a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
--- a/net/ipv4/ipvs/ip_vs_app.c	Mon Sep 22 11:19:05 2003
+++ b/net/ipv4/ipvs/ip_vs_app.c	Mon Sep 22 11:19:05 2003
@@ -222,6 +222,8 @@
 		ip_vs_app_inc_release(inc);
 	}
 
+	list_del(&app->a_list);
+
 	up(&__ip_vs_app_mutex);
 
 	/* decrease the module use count */
diff -Nru a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
--- a/net/ipv4/ipvs/ip_vs_rr.c	Mon Sep 22 11:19:05 2003
+++ b/net/ipv4/ipvs/ip_vs_rr.c	Mon Sep 22 11:19:05 2003
@@ -73,12 +73,12 @@
 			continue;
 		}
 		
-	
 		dest = list_entry(q, struct ip_vs_dest, n_list);
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0)
 			/* HIT */
 			goto out;
+		q = q->next;
 	} while (q != p);
 	write_unlock(&svc->sched_lock);
 	return NULL;
