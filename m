From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] softmac: Fix missing mutex unlock
Date: Sun, 10 Dec 2006 15:40:16 -0600
Message-ID: <457C7EC0.mail8UV112DQV@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.rdc-kc.rr.com ([24.94.166.129]:47461 "EHLO
	ms-smtp-03.rdc-kc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762648AbWLJVk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 16:40:57 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

ieee80211softmac_wx_get_genie locks the associnfo mutex at
function exit. This patch fixes it. The patch is against Linus'
tree (commit af1713e0).

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Michael Buesch <mb@bu3sch.de>
Acked-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

John,

This patch should be applied to wireless-2.6, pushed upstream to 2.6.20.
It will also be sent to -stable.

Larry


diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 480d72c..fa2f7da 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -463,7 +463,7 @@ ieee80211softmac_wx_get_genie(struct net
 			err = -E2BIG;
 	}
 	spin_unlock_irqrestore(&mac->lock, flags);
-	mutex_lock(&mac->associnfo.mutex);
+	mutex_unlock(&mac->associnfo.mutex);
 
 	return err;
 }

