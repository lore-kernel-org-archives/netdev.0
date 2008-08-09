From: roel kluin <roel.kluin@gmail.com>
Subject: [PATCH] bnx2x: precedence confusion !x & y
Date: Sat, 09 Aug 2008 00:27:15 -0400
Message-ID: <489D1CA3.80504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: yanivr@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:1687 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764717AbYHHW07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 18:26:59 -0400
Received: by nf-out-0910.google.com with SMTP id d3so488453nfc.21
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 15:26:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

! has a higher precedence than &

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index af251a5..272a4bd 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7202,7 +7202,7 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 	bp->link_params.req_flow_ctrl = (bp->port.link_config &
 					 PORT_FEATURE_FLOW_CONTROL_MASK);
 	if ((bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO) &&
-	    (!bp->port.supported & SUPPORTED_Autoneg))
+	    !(bp->port.supported & SUPPORTED_Autoneg))
 		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
 	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d  req_flow_ctrl 0x%x"
