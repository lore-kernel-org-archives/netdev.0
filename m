From: Robert Schulze <rob@net-pr.de>
Subject: [PATCH] airo: make debug-like messages printed by airo_print_dbg()
Date: Sat, 08 Jul 2006 17:59:13 +0200
Message-ID: <44AFD651.8030801@net-pr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p15181122.pureserver.info ([212.227.60.11]:55200 "EHLO
	p15181122.pureserver.info") by vger.kernel.org with ESMTP
	id S964866AbWGHPx4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 11:53:56 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think that messages like

airo(eth1): cmd= 111

airo(eth1): status= 7f11

airo(eth1): Rsp0= 2

airo(eth1): Rsp1= 0

airo(eth1): Rsp2= 0

are interesting to normal users, so switch them from airo_print_err() to airo_print_dbg().
Furthermore, remove implicit linefeed in those messages, as they are handled by airo_print().

with kind regards,
Robert Schulze

--- linux-2.6.17.1/drivers/net/wireless/airo.c.orig	2006-07-08 14:02:12.000000000 +0200
+++ linux-2.6.17.1/drivers/net/wireless/airo.c	2006-07-08 17:36:08.000000000 +0200
@@ -3897,11 +3897,11 @@ static u16 issuecommand(struct airo_info
  	pRsp->rsp1 = IN4500(ai, RESP1);
  	pRsp->rsp2 = IN4500(ai, RESP2);
  	if ((pRsp->status & 0xff00)!=0 && pCmd->cmd != CMD_SOFTRESET) {
-		airo_print_err(ai->dev->name, "cmd= %x\n", pCmd->cmd);
-		airo_print_err(ai->dev->name, "status= %x\n", pRsp->status);
-		airo_print_err(ai->dev->name, "Rsp0= %x\n", pRsp->rsp0);
-		airo_print_err(ai->dev->name, "Rsp1= %x\n", pRsp->rsp1);
-		airo_print_err(ai->dev->name, "Rsp2= %x\n", pRsp->rsp2);
+		airo_print_dbg(ai->dev->name, "cmd= %x", pCmd->cmd);
+		airo_print_dbg(ai->dev->name, "status= %x", pRsp->status);
+		airo_print_dbg(ai->dev->name, "Rsp0= %x", pRsp->rsp0);
+		airo_print_dbg(ai->dev->name, "Rsp1= %x", pRsp->rsp1);
+		airo_print_dbg(ai->dev->name, "Rsp2= %x", pRsp->rsp2);
  	}

  	// clear stuck command busy if necessary
