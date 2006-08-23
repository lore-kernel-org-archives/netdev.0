From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx-softmac - set correct value in mac_suspended for ifdown/ifup sequence
Date: Wed, 23 Aug 2006 10:03:23 +0200
Message-ID: <200608231003.24043.mb@bu3sch.de>
References: <44EB8019.3080006@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37291
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932379AbWHWIEJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 04:04:09 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44EB8019.3080006@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 00:07, Larry Finger wrote:
> John,
> 
> Please apply this to wireless-2.6.
> 
> Michael - bcm43xx-d80211 probably needs this as well.
> 
> Larry
> 
> ---------------------------------------------------
> 
> When bcm43xx-softmac is given an ifdown/ifup sequence, the value for bcm->mac_suspended ends up 
> wrong, which leads to a large number of assert(bcm->mac_suspended>=0) messages. This one-line patch 
> fixes this problem.

I think the following is the correct fix for the issue.
It is already in the d80211 branch. (Seems like it got lost somehow).
Can you test this?

Signed-off-by: Michael Buesch <mb@bu3sch.de>

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
