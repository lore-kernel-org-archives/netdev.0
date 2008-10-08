From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 2/3] jme: Faulty IRQ handle bug fix
Date: Thu, 9 Oct 2008 05:57:35 +0800
Message-ID: <20081008215735.M67730@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>,
	akeemting <akeem@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 220-133-139-86.HINET-IP.hinet.net ([220.133.139.86]:34535 "EHLO
	cooldavid.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbYJHV6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:58:02 -0400
In-Reply-To: <48D27CDA.50501@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Jeff, David:

This patch:

    Fix IRQ handle bug when interrupt mode.

    The driver was incorrectly handled and returned IRQ_HANDLED
    while the device is not generating the interrupt.
    It happened due to faulty determination of interrupt status register.

    The patch is also available at:
    http://cooldavid.org/download/jme.net-next-2.6.20081009.2.patch

    Found by: "Ethan" <ethanhsiao@jmicron.com>
    Fixed by: "akeemting" <akeem@jmicron.com>
    Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 635f616..3ab2442 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1463,7 +1463,7 @@ jme_intr(int irq, void *dev_id)
 	/*
 	 * Check if it's really an interrupt for us
 	 */
-	if (unlikely(intrstat == 0))
+	if (unlikely((intrstat & INTR_ENABLE) == 0))
 		return IRQ_NONE;
 
 	/*

