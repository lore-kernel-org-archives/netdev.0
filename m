From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH] mwifiex: fix unconditional error return in .add_virtual_intf callback
Date: Fri,  1 Jul 2016 15:39:42 -0400
Message-ID: <1467401982-18943-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Nishant Sarmukadam <nishants@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:45405
	"EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbcGATsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 15:48:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 7311ea850079 ("mwifiex: fix AP start problem for newly added
interface") attempted to fix an issue when a new AP interface is added.

But the patch didn't check the return value of the functions doing the
firmware calls and returned an error even if the functions didn't fail.

This prevents the network device to be registered properly, so fix it.

Fixes: commit 7311ea850079 ("mwifiex: fix AP start problem for newly added interface")
Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index 99e8cf1ad610..5de9f63e2c01 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -2865,9 +2865,11 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 
 	ret = mwifiex_send_cmd(priv, HostCmd_CMD_SET_BSS_MODE,
 			       HostCmd_ACT_GEN_SET, 0, NULL, true);
+	if (ret)
 		return ERR_PTR(ret);
 
 	ret = mwifiex_sta_init_cmd(priv, false, false);
+	if (ret)
 		return ERR_PTR(ret);
 
 	mwifiex_setup_ht_caps(&wiphy->bands[NL80211_BAND_2GHZ]->ht_cap, priv);
-- 
2.5.5
