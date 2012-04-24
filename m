From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 2/4] mISDN: Fixed hardware bridging/conference check routine of mISDN_dsp.ko.
Date: Tue, 24 Apr 2012 14:51:50 +0200
Message-ID: <1335271912-5269-3-git-send-email-kkeil@linux-pingi.de>
References: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Andreas Eversberg <jolly@eversberg.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:61411 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab2DXMym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 08:54:42 -0400
In-Reply-To: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>

In some cases the hardware bridging/conference (2-n parties) was selected,
but still pure software bridging/conference was used.

Signed-off-by: Andreas Eversberg <jolly@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/dsp_cmx.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index b7589c2..0c104b9 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -742,8 +742,8 @@ dsp_cmx_hardware(struct dsp_conf *conf, struct dsp *dsp)
 					       member->dsp->pcm_slot_tx,
 					       member->dsp->pcm_bank_tx,
 					       member->dsp->pcm_bank_rx);
-				conf->hardware = 0;
-				conf->software = 1;
+				conf->hardware = 1;
+				conf->software = tx_data;
 				return;
 			}
 			/* find a new slot */
@@ -834,8 +834,8 @@ dsp_cmx_hardware(struct dsp_conf *conf, struct dsp *dsp)
 					       nextm->dsp->name,
 					       member->dsp->pcm_slot_tx,
 					       member->dsp->pcm_slot_rx);
-				conf->hardware = 0;
-				conf->software = 1;
+				conf->hardware = 1;
+				conf->software = tx_data;
 				return;
 			}
 			/* find two new slot */
@@ -939,8 +939,11 @@ dsp_cmx_hardware(struct dsp_conf *conf, struct dsp *dsp)
 	/* for more than two members.. */
 
 	/* if all members already have the same conference */
-	if (all_conf)
+	if (all_conf) {
+		conf->hardware = 1;
+		conf->software = tx_data;
 		return;
+	}
 
 	/*
 	 * if there is an existing conference, but not all members have joined
@@ -1013,6 +1016,8 @@ dsp_cmx_hardware(struct dsp_conf *conf, struct dsp *dsp)
 			dsp_cmx_hw_message(member->dsp,
 					   MISDN_CTRL_HFC_CONF_JOIN, current_conf, 0, 0, 0);
 		}
+		conf->hardware = 1;
+		conf->software = tx_data;
 		return;
 	}
 
-- 
1.7.3.4
