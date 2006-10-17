From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] bcm43xx: Readd dropped assignment
Date: Wed, 18 Oct 2006 00:12:12 +0100 (BST)
Message-ID: <20061017231212.A73D77B40A0@zog.reactivated.net>
Cc: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:10109 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751055AbWJQXMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 19:12:08 -0400
To: linville@tuxdriver.com
Cc: Larry.Finger@lwfinger.net
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger pointed out a problem with my ieee80211 IV/ICV stripping patch,
which I forgot about. Sorry about that.

The patch readds the frame_ctl assignment which was accidently dropped.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
 		break;
 	}
 
+	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
 	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
 	case IEEE80211_FTYPE_MGMT:
 		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
