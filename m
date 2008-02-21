From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] mac80211: fix debugfs_sta print_mac() warning
Date: Thu, 21 Feb 2008 11:22:12 +0100
Message-ID: <1203589332.17534.150.camel@johannes.berg>
References: <1203587699.17534.135.camel@johannes.berg>
	 <20080221.020343.190715910.davem@davemloft.net>
	 <1203588498.20345.20.camel@brick>
	 <20080221.021228.09081608.davem@davemloft.net>
	 <1203588993.20345.27.camel@brick> (sfid-20080221_101622_275557_F35DFAB3)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1203588993.20345.27.camel@brick> (sfid-20080221_101622_275557_F35DFAB3)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When print_mac() was marked as __pure to avoid emitting a function
call in pr_debug() scenarios, a warning in this code surfaced since
it relies on the fact that the buffer is modified and doesn't use
the return value. This patch makes it use the return value instead.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Reported-by: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/debugfs_sta.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- everything.orig/net/mac80211/debugfs_sta.c	2008-02-21 11:17:48.000000000 +0100
+++ everything/net/mac80211/debugfs_sta.c	2008-02-21 11:17:59.000000000 +0100
@@ -297,12 +297,13 @@ STA_OPS_WR(agg_status);
 void ieee80211_sta_debugfs_add(struct sta_info *sta)
 {
 	struct dentry *stations_dir = sta->local->debugfs.stations;
-	DECLARE_MAC_BUF(mac);
+	DECLARE_MAC_BUF(mbuf);
+	u8 *mac;
 
 	if (!stations_dir)
 		return;
 
-	print_mac(mac, sta->addr);
+	mac = print_mac(mbuf, sta->addr);
 
 	sta->debugfs.dir = debugfs_create_dir(mac, stations_dir);
 	if (!sta->debugfs.dir)
