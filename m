From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Fill enc_capa in GIWRANGE handler
Date: Fri,  1 Dec 2006 00:57:11 +0000 (GMT)
Message-ID: <20061201005711.3B8F07B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:18758 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1031664AbWLAA5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 19:57:09 -0500
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is needed for NetworkManager users to connect to WPA networks.
Pointed out by Matthew Campbell.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_mac.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -615,6 +615,9 @@ int zd_mac_get_range(struct zd_mac *mac,
 	range->we_version_compiled = WIRELESS_EXT;
 	range->we_version_source = 20;
 
+	range->enc_capa = IW_ENC_CAPA_WPA |  IW_ENC_CAPA_WPA2 |
+			  IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
+
 	ZD_ASSERT(!irqs_disabled());
 	spin_lock_irq(&mac->lock);
 	regdomain = mac->regdomain;
