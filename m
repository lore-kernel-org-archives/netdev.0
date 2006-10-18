From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH wireless-2.6] ieee80211: don't flood log with errors
Date: Wed, 18 Oct 2006 19:34:40 +0200
Message-ID: <20061018193440.001465a3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:56972 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161154AbWJRReq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 13:34:46 -0400
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "ieee80211: Workaround malformed 802.11 frames from AP" patch (see
http://kernel.org/git/?p=linux/kernel/git/linville/wireless-2.6.git;a=commit;h=f09fc44d8c25f22c4d985bb93857338ed02feac6 )
fixes the problem with some buggy APs but also converts debug message into
an error one. This floods the log with errors when you are near such AP (you
get a message for every beacon). This patch reverts the error message back
to the debug one.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/ieee80211/ieee80211_rx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1078,12 +1078,12 @@ static int ieee80211_parse_info_param(st
 
 	while (length >= sizeof(*info_element)) {
 		if (sizeof(*info_element) + info_element->len > length) {
-			IEEE80211_ERROR("Info elem: parse failed: "
-					"info_element->len + 2 > left : "
-					"info_element->len+2=%zd left=%d, id=%d.\n",
-					info_element->len +
-					sizeof(*info_element),
-					length, info_element->id);
+			IEEE80211_DEBUG_MGMT("Info elem: parse failed: "
+					     "info_element->len + 2 > left : "
+					     "info_element->len+2=%zd left=%d, id=%d.\n",
+					     info_element->len +
+					     sizeof(*info_element),
+					     length, info_element->id);
 			/* We stop processing but don't return an error here
 			 * because some misbehaviour APs break this rule. ie.
 			 * Orinoco AP1000. */


-- 
Jiri Benc
SUSE Labs
