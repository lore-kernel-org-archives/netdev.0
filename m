From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 7/7] d80211: do not pass an invalid key index to set_key()
Date: Wed, 6 Dec 2006 16:45:40 -0800
Message-ID: <20061207004540.GG16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33862 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937856AbWLGApl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:41 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="alg-none-keyix.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a hardware key has not been configured then there is no point
to calling DISABLE_KEY.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -612,7 +612,7 @@ static int ieee80211_set_encryption(stru
 
 	if (alg == ALG_NONE) {
 		keyconf = NULL;
-		if (try_hwaccel && key && local->ops->set_key &&
+		if (try_hwaccel && key && key->hw_key_idx != -1 && local->ops->set_key &&
 		    (keyconf = ieee80211_key_data2conf(local, key)) != NULL &&
 		    local->ops->set_key(local_to_hw(local), DISABLE_KEY,
 				       sta_addr, keyconf, sta ? sta->aid : 0)) {

--
