From: Alex Hung <alex.hung@canonical.com>
Subject: [PATCH] rfkill: Add handling when rfkill's type is RFKILL_TYPE_ALL.
Date: Mon, 21 May 2012 16:37:19 +0800
Message-ID: <1337589439-14605-1-git-send-email-alex.hung@canonical.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alex.hung@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This rfkill type is supposed to be able to toggles the status of all wireless
devices; however, no wireless devices will register itself with type 
RFKILL_TYPE_ALL and thus it was previously ignored in __rfkill_switch_all.

Signed-off-by: Alex Hung <alex.hung@canonical.com>
---
 net/rfkill/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 5be1957..84dd71a 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -324,7 +324,7 @@ static void __rfkill_switch_all(const enum rfkill_type type, bool blocked)
 
 	rfkill_global_states[type].cur = blocked;
 	list_for_each_entry(rfkill, &rfkill_list, node) {
-		if (rfkill->type != type)
+		if (rfkill->type != type && type != RFKILL_TYPE_ALL)
 			continue;
 
 		rfkill_set_block(rfkill, blocked);
-- 
1.7.0.4
