From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx-softmac - set correct value in mac_suspended for
 ifdown/ifup sequence
Date: Tue, 22 Aug 2006 17:07:21 -0500
Message-ID: <44EB8019.3080006@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch@freenet.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:40172 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750971AbWHWACt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 20:02:49 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

Please apply this to wireless-2.6.

Michael - bcm43xx-d80211 probably needs this as well.

Larry

---------------------------------------------------

When bcm43xx-softmac is given an ifdown/ifup sequence, the value for bcm->mac_suspended ends up 
wrong, which leads to a large number of assert(bcm->mac_suspended>=0) messages. This one-line patch 
fixes this problem.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

index b095f3c..f532f3c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3484,6 +3484,7 @@ int bcm43xx_select_wireless_core(struct
  	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
  	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
  	bcm43xx_security_init(bcm);
+	bcm->mac_suspended = 1;
  	ieee80211softmac_start(bcm->net_dev);

  	/* Let's go! Be careful after enabling the IRQs.
