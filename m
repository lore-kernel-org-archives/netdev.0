From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] isdn: fix section mismatch warning in hfc_sx.c
Date: Fri,  8 Feb 2008 21:00:04 +0100
Message-ID: <1202500804-32020-4-git-send-email-sam@ravnborg.org>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:43412 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbYBHT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:59:58 -0500
In-Reply-To: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warning:
WARNING: drivers/isdn/hisax/built-in.o(.text+0x35818): Section mismatch in reference from the function hfcsx_card_msg() to the function .devinit.text:inithfcsx()

hfcsx_card_msg() may be called outside __devinit context.
Following the program logic is looks like the CARD_INIT branch
will only be taken under __devinit context but to be consistent
remove the __devinit annotation of inithfcsx() so we
do not mix non-__devinit and __devinit code.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Karsten Keil <kkeil@suse.de>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: David Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/hfc_sx.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 4fd09d2..05482d2 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1330,8 +1330,7 @@ hfcsx_bh(struct work_struct *work)
 /********************************/
 /* called for card init message */
 /********************************/
-static void __devinit
-inithfcsx(struct IsdnCardState *cs)
+static void inithfcsx(struct IsdnCardState *cs)
 {
 	cs->setstack_d = setstack_hfcsx;
 	cs->BC_Send_Data = &hfcsx_send_data;
-- 
1.5.4.rc3.14.g44397

