From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] d80211: Fix TX/RX rates
Date: Sun, 15 Oct 2006 20:14:07 +0200
Message-ID: <200610152014.08260.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>, geromanas@mailas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:2357 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1030191AbWJOSPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 14:15:14 -0400
Received: by nf-out-0910.google.com with SMTP id c2so571064nfe
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2006 11:15:12 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch correctly initializes the force_unicast_rateidx
and max_ratectrl_rateidx. This was not done previously
and caused a bug in rf80211_simple where when
rate_control_simple_get_rate() was called, the incorrect
rate was selected from the list.

Signed-off-by Modestas Vainius <geromanas@mailas.com>
Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 86062c9..265a1dc 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4414,6 +4414,8 @@ struct net_device *ieee80211_alloc_hw(si
         sdata->dev = mdev;
         sdata->master = mdev;
         sdata->local = local;
+	sdata->u.ap.force_unicast_rateidx = -1;
+	sdata->u.ap.max_ratectrl_rateidx = -1;
 	ieee80211_if_sdata_init(sdata);
         list_add_tail(&sdata->list, &local->sub_if_list);
 
