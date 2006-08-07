From: Jouni Malinen <jkm@devicescape.com>
Subject: [PATCH wireless-dev 6/6] d80211: Fix TKIP replay protection
Date: Mon, 07 Aug 2006 16:16:14 -0700
Message-ID: <20060807231939.314173160@localhost>
References: <20060807231608.888744720@localhost>
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	jkm@devicescape.com, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-32.dex002.intermedia.net ([64.78.21.117]:22277 "EHLO
	dhost002-32.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751199AbWHGXYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:24:00 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline; filename=tkip_replay_prot.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed TKIP replay protection for the case where hwaccel is enabled.
rx_initialized flag was not set in this case and the TSC validation
was skipped for the frames.

Signed-off-by: Jouni Malinen <jkm@devicescape.com>

Index: wireless-dev/net/d80211/tkip.c
===================================================================
--- wireless-dev.orig/net/d80211/tkip.c
+++ wireless-dev/net/d80211/tkip.c
@@ -286,6 +286,7 @@ int ieee80211_tkip_decrypt_data(struct c
 
 	if (only_iv) {
 		res = TKIP_DECRYPT_OK;
+		key->u.tkip.rx_initialized[queue] = 1;
 		goto done;
 	}
 

--
-- 
Jouni Malinen                                            PGP id EFC895FA
