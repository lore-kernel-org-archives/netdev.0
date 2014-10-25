From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] cfg80211: fix set but not used warning in nl80211_channel_switch()
Date: Sat, 25 Oct 2014 17:57:35 +0200
Message-ID: <1414252655-20506-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:62284 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752009AbaJYS0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 14:26:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

radar_detect_width is unused since commit 97dc94f1d933
("cfg80211: remove channel_switch combination check")

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/wireless/nl80211.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index cb9f5a4..2a2a53a 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -5923,7 +5923,6 @@ static int nl80211_channel_switch(struct sk_buff *skb, struct genl_info *info)
 	 * function is called under RTNL lock, so this should not be a problem.
 	 */
 	static struct nlattr *csa_attrs[NL80211_ATTR_MAX+1];
-	u8 radar_detect_width = 0;
 	int err;
 	bool need_new_beacon = false;
 	int len, i;
@@ -6051,10 +6050,8 @@ skip_beacons:
 	if (err < 0)
 		return err;
 
-	if (err > 0) {
-		radar_detect_width = BIT(params.chandef.width);
+	if (err > 0)
 		params.radar_required = true;
-	}
 
 	if (info->attrs[NL80211_ATTR_CH_SWITCH_BLOCK_TX])
 		params.block_tx = true;
-- 
1.9.3
