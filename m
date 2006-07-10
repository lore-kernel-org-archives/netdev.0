From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx-d80211 (try 2): Fix an off-by-one condition in handle_irq_noise
Date: Mon, 10 Jul 2006 18:16:01 -0500
Message-ID: <44B2DFB1.8080204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:28612 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965038AbWGJXQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 19:16:37 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An assert statement near the start of handle_irq_noise in the d80211 version of bcm43xx_main.c is
there to protect against out of bound addressing using variable bcm->noisecalc.nr_samples. The
arrays in question have a dimension of 8, thus the value must be < 8. This patch mirrors the one
submitted earlier for the softmac version of bcm43xx.

Signed-Off-By: Larry.Finger <Larry.Finger@lwfinger.net>

========================================================

index a400bd6..1db471e 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1434,7 +1434,7 @@ static void handle_irq_noise(struct bcm4
  		goto generate_new;

  	/* Get the noise samples. */
-	assert(bcm->noisecalc.nr_samples <= 8);
+	assert(bcm->noisecalc.nr_samples < 8);
  	i = bcm->noisecalc.nr_samples;
  	noise[0] = limit_value(noise[0], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);
  	noise[1] = limit_value(noise[1], 0, ARRAY_SIZE(radio->nrssi_lt) - 1);

========================

