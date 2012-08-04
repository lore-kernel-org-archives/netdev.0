From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH] mISDN: Bugfix for layer2 fixed TEI mode
Date: Sat,  4 Aug 2012 12:14:25 +0200
Message-ID: <1344075265-18999-1-git-send-email-keil@b1-systems.de>
Cc: davem@davemloft.net, stable@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([217.11.58.35]:33762 "EHLO mx1.b1-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab2HDKO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 06:14:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a fixed TEI is used, the initial state of the layer 2 statmachine need to be
4 (TEI assigned). This was true only for Point to Point connections, but not
for the other fixed TEIs. It was not found before, because usually only the
TEI 0 is used as fixed TEI for PtP mode, but if you try X31 packet mode
connections with SAPI 16, TEI 1, it did fail.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
Cc: <stable@vger.kernel.org> # 3.5.x
---
 drivers/isdn/mISDN/layer2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 0dc8abc..949cabb 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -2222,7 +2222,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, int tei,
 	InitWin(l2);
 	l2->l2m.fsm = &l2fsm;
 	if (test_bit(FLG_LAPB, &l2->flag) ||
-	    test_bit(FLG_PTP, &l2->flag) ||
+	    test_bit(FLG_FIXED_TEI, &l2->flag) ||
 	    test_bit(FLG_LAPD_NET, &l2->flag))
 		l2->l2m.state = ST_L2_4;
 	else
-- 
1.7.7
