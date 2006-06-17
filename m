From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Sat, 17 Jun 2006 11:23:28 -0700
Message-ID: <1150568608.26368.49.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC041BD1E@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jk@blackdown.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:18438 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750778AbWFQSWk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 14:22:40 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC041BD1E@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-16 at 20:37 -0700, Michael Chan wrote:
> David Miller wrote:
> 
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Fri, 16 Jun 2006 18:27:32 -0700
> > 
> > > In the meantime, I wonder if we should disable TSO by default on the
> > > 5780 chip for 2.6.17.
> > 
> > Sounds reasonable.  Would we disable it for all chips that set
> > TG3_FLG2_5780_CLASS or a specific variant?
> > 
> Yes, let's disable it for all TG3_FLG2_5780_CLASS chips for now
> until we figure out what's going on.

David, Here's the patch if you haven't already made one:

[TG3]: Disable TSO by default on 5780 class chips.

Disable TSO by default on 5780, 5714, and 5715 chips for now while we
investigate the reported tx timeouts by Juergen Kreileder.  Thanks to
Juergen for reporting the problem.

Update version to 3.60.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 862c226..607d87e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -69,8 +69,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.59"
-#define DRV_MODULE_RELDATE	"June 8, 2006"
+#define DRV_MODULE_VERSION	"3.60"
+#define DRV_MODULE_RELDATE	"June 17, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -11385,7 +11385,11 @@ static int __devinit tg3_init_one(struct
 	 * Firmware TSO on older chips gives lower performance, so it
 	 * is off by default, but can be enabled using ethtool.
 	 */
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO)
+	/* Disable TSO by default on all 5780 class chips because
+	 * of reported tx timeouts.
+	 */
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) &&
+	   !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		dev->features |= NETIF_F_TSO;
 
 #endif


