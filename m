From: Takashi Iwai <tiwai@suse.de>
Subject: [PATCH 1/2] net: Fix Yukon-2 Optima TCP offload setup
Date: Thu,  3 Dec 2009 16:12:01 +0100
Message-ID: <1259853122-21134-2-git-send-email-tiwai@suse.de>
References: <1259853122-21134-1-git-send-email-tiwai@suse.de>
Cc: Takashi Iwai <tiwai@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56699 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756308AbZLCPMG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 10:12:06 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 0FE9174609
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 16:12:13 +0100 (CET)
In-Reply-To: <1259853122-21134-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the TCP offload setup for Yukon-2 Optima.
It requires SKY2_HW_NE_LE flag unlike Ultra 2.

Signed-off-by: Takashi Iwai <tiwai@suse.de>
---
 drivers/net/sky2.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a3d9991..0718cdd 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2968,8 +2968,13 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 		break;
 
 	case CHIP_ID_YUKON_UL_2:
+		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_ADV_POWER_CTL;
+		break;
+
 	case CHIP_ID_YUKON_OPT:
 		hw->flags = SKY2_HW_GIGABIT
+			| SKY2_HW_NEW_LE
 			| SKY2_HW_ADV_POWER_CTL;
 		break;
 
-- 
1.6.5.3

