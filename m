From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH Take 2] bcm43xx-softmac - set correct value in mac_suspended
 for ifdown/ifup sequence]
Date: Wed, 23 Aug 2006 10:04:01 -0500
Message-ID: <44EC6E61.3040509@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:49644 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964926AbWHWPE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:04:26 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

This is a better solution of the issue. Please disregard the patch sent yesterday.

Larry

-------------------------------

When bcm43xx-softmac is given an ifdown/ifup sequence, the value for bcm->mac_suspended ends up
wrong, which leads to a large number of assert(bcm->mac_suspended>=0) messages. This one-line patch
fixes this problem.

I think the following is the correct fix for the issue.
It is already in the d80211 branch. (Seems like it got lost somehow).

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-08-23 10:00:27.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-08-23 10:01:45.000000000 +0200
@@ -3349,6 +3349,8 @@
  	memset(bcm->dma_reason, 0, sizeof(bcm->dma_reason));
  	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;

+	bcm->mac_suspended = 1;
+
  	/* Noise calculation context */
  	memset(&bcm->noisecalc, 0, sizeof(bcm->noisecalc));


-- 
Greetings Michael.

