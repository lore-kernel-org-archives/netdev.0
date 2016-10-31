From: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
Subject: [PATCH v7 1/2] nl80211: multicast_to_unicast can be changed while IFF_UP
Date: Mon, 31 Oct 2016 14:40:59 +0100
Message-ID: <1477921260-24556-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        projekt-wlan-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no need to prevent toggling multicast_to_unicast while
interface is already up. This change simplifies reconfiguration
from hostapd.

Signed-off-by: Michael Braun <michael-dev-1SGGS//iJ+Y38rf8aCqVIw@public.gmane.org>
---
 net/wireless/nl80211.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 5349c63..7554400 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -11006,9 +11006,6 @@ static int nl80211_set_multicast_to_unicast(struct sk_buff *skb,
 	const struct nlattr *nla;
 	bool enabled;
 
-	if (netif_running(dev))
-		return -EBUSY;
