From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] mac80211: use list_move instead of list_del/list_add
Date: Thu, 6 Sep 2012 13:20:53 +0800
Message-ID: <CAPgLHd_VrjzzfPDsd3KKzgX2bKJ47zUCJmsQO+Q49ajNVLnTVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:36088 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2IFFUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 01:20:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move() instead of list_del() + list_add().

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/mac80211/offchannel.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index 635c325..7fbf99d 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -227,8 +227,7 @@ static void ieee80211_hw_roc_start(struct work_struct *work)
 			u32 dur = dep->duration;
 			dep->duration = dur - roc->duration;
 			roc->duration = dur;
-			list_del(&dep->list);
-			list_add(&dep->list, &roc->list);
+			list_move(&dep->list, &roc->list);
 		}
 	}
  out_unlock:
