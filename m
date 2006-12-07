From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 7/7] d80211: do not pass an invalid key index to set_key()
Date: Thu, 7 Dec 2006 09:01:25 -0800
Message-ID: <20061207170125.GB1476@devicescape.com>
References: <20061207004540.GG16252@devicescape.com> <20061207132505.049363e6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:58294 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032460AbWLGRBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 12:01:30 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061207132505.049363e6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Use HW_KEY_IDX_INVALID, please.

oops, here you go (also fixed bad indentation):

------

d80211: do not pass an invalid key index to set_key()

If a hardware key has not been configured then there is no point
to calling DISABLE_KEY.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -612,7 +612,9 @@ static int ieee80211_set_encryption(stru
 
 	if (alg == ALG_NONE) {
 		keyconf = NULL;
-		if (try_hwaccel && key && local->ops->set_key &&
+		if (try_hwaccel && key &&
+		    key->hw_key_idx != HW_KEY_IDX_INVALID &&
+		    local->ops->set_key &&
 		    (keyconf = ieee80211_key_data2conf(local, key)) != NULL &&
 		    local->ops->set_key(local_to_hw(local), DISABLE_KEY,
 				       sta_addr, keyconf, sta ? sta->aid : 0)) {
