From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH] NET: nl80211, fix lock imbalance and netdev referencing
Date: Wed,  7 Jul 2010 15:02:46 +0200
Message-ID: <1278507766-309-1-git-send-email-jirislaby@gmail.com>
Cc: jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, Jouni Malinen <j@w1.fi>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found that nl80211_set_wiphy imporperly handles a lock and netdev
reference and contains unreachable code. It is because there return statement
isntead of assignment to result variable. Fix that.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jouni Malinen <j@w1.fi>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/wireless/nl80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 85285b4..fbfac58 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -877,7 +877,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		int idx, mbm = 0;
 
 		if (!rdev->ops->set_tx_power) {
-			return -EOPNOTSUPP;
+			result = -EOPNOTSUPP;
 			goto bad_res;
 		}
 
-- 
1.7.1
