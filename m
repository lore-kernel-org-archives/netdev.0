From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/15] tg3: Do not enable APE on bcm5700
Date: Mon, 3 Nov 2008 02:12:05 -0800
Message-ID: <1225751622.6181@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4905 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756680AbYKCWdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 17:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With older versions of the NVRAM format, the driver may mistakenly
determine that APE is enabled.  Make sure this doesn't happen by
restricting the ENABLE_APE check to devices known to have more
recent NVRAM image formats.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 45fcbc3..978d1f0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11441,8 +11441,11 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
 				tp->tg3_flags2 |= TG3_FLG2_ASF_NEW_HANDSHAKE;
 		}
-		if (nic_cfg & NIC_SRAM_DATA_CFG_APE_ENABLE)
+
+		if ((nic_cfg & NIC_SRAM_DATA_CFG_APE_ENABLE) &&
+			(tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 			tp->tg3_flags3 |= TG3_FLG3_ENABLE_APE;
+
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES &&
 		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
-- 
1.5.6.4



