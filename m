From: Brice Goglin <brice@myri.com>
Subject: [PATCH 03/16] myri10ge: increase and fix handoff timeout
Date: Fri, 09 May 2008 02:17:16 +0200
Message-ID: <4823980C.1060405@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756623AbYEIAqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:12 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increase the handoff timeout to 512ms so as to give the aeluros based
NICs sufficient time to handoff without relying on the msleep() being
sloppy, and accidentally sleeping way longer than the 20ms we specified
in 20 separate 1ms sleeps.

Fix typo in the handoff sleep delay, which made it additive, not
exponential.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:00:45.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:02:04.000000000 +0200
@@ -682,8 +682,8 @@
 	msleep(1);
 	mb();
 	i = 0;
-	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 20) {
-		msleep(1);
+	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 9) {
+		msleep(1 << i);
 		i++;
 	}
 	if (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA) {


