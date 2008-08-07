From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] bnx2x: fix logical op
Date: Thu, 7 Aug 2008 13:53:14 -0700
Message-ID: <20080807135314.8d87e1a2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, eilong@broadcom.com,
	akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:42364 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbYHGU43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 16:56:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
cc: eilong@broadcom.com

Fix dubious logical operation that was found by sparse:
linux-next-20080807/drivers/net/bnx2x_main.c:7205:27: warning: dubious: !x & y

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20080807.orig/drivers/net/bnx2x_main.c
+++ linux-next-20080807/drivers/net/bnx2x_main.c
@@ -7202,7 +7202,7 @@ static void __devinit bnx2x_link_setting
 	bp->link_params.req_flow_ctrl = (bp->port.link_config &
 					 PORT_FEATURE_FLOW_CONTROL_MASK);
 	if ((bp->link_params.req_flow_ctrl == FLOW_CTRL_AUTO) &&
-	    (!bp->port.supported & SUPPORTED_Autoneg))
+	    !(bp->port.supported & SUPPORTED_Autoneg))
 		bp->link_params.req_flow_ctrl = FLOW_CTRL_NONE;
 
 	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d  req_flow_ctrl 0x%x"
