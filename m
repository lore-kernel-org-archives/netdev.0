From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH] ieee80211softmac: Fix mutex_lock at exit of ieee80211_softmac_get_genie
Date: Sun, 10 Dec 2006 18:27:01 +0100
Message-ID: <20061210172701.GA29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:56343 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762273AbWLJR1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 12:27:02 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211softmac_wx_get_genie locks the associnfo mutex at
function exit. This patch fixes it. The patch is against Linus'
tree (commit af1713e0).

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
---
 net/ieee80211/softmac/ieee80211softmac_wx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.4.1

