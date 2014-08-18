From: Michal Kazior <michal.kazior@tieto.com>
Subject: [PATCH] mac80211: fix channel switch for chanctx-based drivers
Date: Mon, 18 Aug 2014 13:19:09 +0200
Message-ID: <1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
References: <1408351816.29649.8.camel@dubbel>
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Luca Coelho <luca@coelho.fi>,
	Michal Kazior <michal.kazior@tieto.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:64136 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbaHRLbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 07:31:15 -0400
Received: by mail-la0-f54.google.com with SMTP id hz20so4496017lab.27
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2014 04:31:13 -0700 (PDT)
In-Reply-To: <1408351816.29649.8.camel@dubbel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new_ctx pointer is set only for non-chanctx
drivers. This yielded a crash for chanctx-based
drivers during channel switch finalization:

  BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
  IP: ieee80211_vif_use_reserved_switch+0x71c/0xb00 [mac80211]

Use an adequate chanctx pointer to fix this.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Michal Kazior <michal.kazior@tieto.com>
---
Note: This is based on mac80211-next/master albeit
it should apply cleanly on wireless-next/master
and v3.17-rc1.

I've verified this fix with iwlmvm & 7260.


 net/mac80211/chan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/chan.c b/net/mac80211/chan.c
index f3317fa..7367e66 100644
--- a/net/mac80211/chan.c
+++ b/net/mac80211/chan.c
@@ -1353,7 +1353,7 @@ static int ieee80211_vif_use_reserved_switch(struct ieee80211_local *local)
 
 			list_del(&sdata->reserved_chanctx_list);
 			list_move(&sdata->assigned_chanctx_list,
-				  &new_ctx->assigned_vifs);
+				  &ctx->assigned_vifs);
 			sdata->reserved_chanctx = NULL;
 
 			ieee80211_vif_chanctx_reservation_complete(sdata);
-- 
1.8.5.3
