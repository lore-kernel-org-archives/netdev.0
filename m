From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Fix infinite loop on dev_mc_unsync()
Date: Fri, 9 Nov 2007 10:11:35 -0500
Message-ID: <20071109151135.GA12982@pogo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While reviewing net/core/dev_mcast.c I found what I think is an 
infinite loop on dev_mc_unsync(). This fixes it. We make use of
this guy on mac80211 in ieee80211_stop(). This is untested.

Signed-off-by: Luis R. Rodriguez <mcgrof-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>

diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 15241cf..5373c03 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -168,8 +168,10 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 	da = from->mc_list;
 	while (da != NULL) {
 		next = da->next;
-		if (!da->da_synced)
+		if (!da->da_synced) {
+			da = next;
 			continue;
+		}
 		__dev_addr_delete(&to->mc_list, &to->mc_count,
 				  da->da_addr, da->da_addrlen, 0);
 		da->da_synced = 0;
