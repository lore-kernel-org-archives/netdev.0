From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 4/7] d80211: fix potential invalid array index returning key information
Date: Wed, 6 Dec 2006 16:45:19 -0800
Message-ID: <20061207004519.GD16252@devicescape.com>
References: <20061207004238.540749000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:33818 "EHLO
	mail.devicescape.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937840AbWLGApT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 19:45:19 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="get_encrypt-overflow.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sdata->keys[] has NUM_DEFAULT_KEYS elements, don't access past that.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -803,7 +803,7 @@ static int ieee80211_ioctl_get_encryptio
 	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
 	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
 		sta = NULL;
-		if (param->u.crypt.idx > NUM_DEFAULT_KEYS) {
+		if (param->u.crypt.idx >= NUM_DEFAULT_KEYS) {
 			param->u.crypt.idx = sdata->default_key ?
 				sdata->default_key->keyidx : 0;
 			return 0;

--
