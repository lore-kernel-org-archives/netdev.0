From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] isdn: fix section mismatch warnings in isac.c and isar.c
Date: Fri,  8 Feb 2008 21:00:03 +0100
Message-ID: <1202500804-32020-3-git-send-email-sam@ravnborg.org>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:49577 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759412AbYBHT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:59:58 -0500
In-Reply-To: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warnings:
WARNING: drivers/isdn/hisax/built-in.o(.text+0x1b276): Section mismatch in reference from the function inithscxisac() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x1b286): Section mismatch in reference from the function inithscxisac() to the function .devinit.text:initisac()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x1fec7): Section mismatch in reference from the function AVM_card_msg() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x21669): Section mismatch in reference from the function AVM_card_msg() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x21671): Section mismatch in reference from the function AVM_card_msg() to the function .devinit.text:initisac()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x2991e): Section mismatch in reference from the function Sedl_card_msg() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x29936): Section mismatch in reference from the function Sedl_card_msg() to the function .devinit.text:initisac()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x2993e): Section mismatch in reference from the function Sedl_card_msg() to the function .devinit.text:initisar()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x2e026): Section mismatch in reference from the function NETjet_S_card_msg() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x2e02e): Section mismatch in reference from the function NETjet_S_card_msg() to the function .devinit.text:initisac()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x37813): Section mismatch in reference from the function BKM_card_msg() to the function .devinit.text:clear_pending_isac_ints()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x37823): Section mismatch in reference from the function BKM_card_msg() to the function .devinit.text:initisac()

initisar(), initisac() and clear_pending_isac_ints()
were all used via a cardmsg fnction - which may be called
ouside __devinit context.
So remove the bogus __devinit annotation of the
above three functions to fix the warnings.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Karsten Keil <kkeil@suse.de>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: David Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/isac.c |    6 ++----
 drivers/isdn/hisax/isar.c |    3 +--
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 6ae9dde..07b1673 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -615,8 +615,7 @@ dbusy_timer_handler(struct IsdnCardState *cs)
 	}
 }
 
-void __devinit
-initisac(struct IsdnCardState *cs)
+void initisac(struct IsdnCardState *cs)
 {
 	cs->setstack_d = setstack_isac;
 	cs->DC_Close = DC_Close_isac;
@@ -647,8 +646,7 @@ initisac(struct IsdnCardState *cs)
 	cs->writeisac(cs, ISAC_MASK, 0x0);
 }
 
-void __devinit
-clear_pending_isac_ints(struct IsdnCardState *cs)
+void clear_pending_isac_ints(struct IsdnCardState *cs)
 {
 	int val, eval;
 
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index c547a66..bfeb9b6 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -1894,8 +1894,7 @@ isar_auxcmd(struct IsdnCardState *cs, isdn_ctrl *ic) {
 	return(0);
 }
 
-void __devinit
-initisar(struct IsdnCardState *cs)
+void initisar(struct IsdnCardState *cs)
 {
 	cs->bcs[0].BC_SetStack = setstack_isar;
 	cs->bcs[1].BC_SetStack = setstack_isar;
-- 
1.5.4.rc3.14.g44397

