From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/7) ipmr.c - convert to alloc_netdev
Date: Wed, 25 Jun 2003 11:41:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114121.2597182c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use time_after to avoid potential for jiffies wrap in timer code.


diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:30:03 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:30:03 2003
@@ -342,9 +342,8 @@
 	cp = &mfc_unres_queue;
 
 	while ((c=*cp) != NULL) {
-		long interval = c->mfc_un.unres.expires - now;
-
-		if (interval > 0) {
+		if (time_after(c->mfc_un.unres.expires, now)) {
+			unsigned long interval = c->mfc_un.unres.expires - now;
 			if (interval < expires)
 				expires = interval;
 			cp = &c->next;
@@ -1291,7 +1290,8 @@
 		       large chunk of pimd to kernel. Ough... --ANK
 		     */
 		    (mroute_do_pim || cache->mfc_un.res.ttls[true_vifi] < 255) &&
-		    jiffies - cache->mfc_un.res.last_assert > MFC_ASSERT_THRESH) {
+		    time_after(jiffies, 
+			       cache->mfc_un.res.last_assert + MFC_ASSERT_THRESH)) {
 			cache->mfc_un.res.last_assert = jiffies;
 			ipmr_cache_report(skb, true_vifi, IGMPMSG_WRONGVIF);
 		}
