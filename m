From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: dead network on JS21 with tg3 driver after flowcontrol
 changes
Date: Thu, 15 May 2008 10:15:20 -0700
Message-ID: <20080515171520.GA20953@localdomain>
References: <20080515121340.GA23033@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: "Olaf Hering" <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1664 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbYEORMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 13:12:10 -0400
In-Reply-To: <20080515121340.GA23033@aepfle.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you were to start with the original file, does the following patch
fix the problem?


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07b3f77..4c248d7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3168,8 +3168,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	err |= tg3_readphy(tp, MII_BMCR, &bmcr);
 
 	if ((tp->link_config.autoneg == AUTONEG_ENABLE) && !force_reset &&
-	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
-	     tp->link_config.flowctrl == tp->link_config.active_flowctrl) {
+	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
 		/* do nothing, just check for link up at the end */
 	} else if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 		u32 adv, new_adv;


