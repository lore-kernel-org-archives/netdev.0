From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] isdn: fix section mismatch warning for ISACVer
Date: Fri,  8 Feb 2008 21:00:02 +0100
Message-ID: <1202500804-32020-2-git-send-email-sam@ravnborg.org>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:49584 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759694AbYBHT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:59:58 -0500
In-Reply-To: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix following warnings:
WARNING: drivers/isdn/hisax/built-in.o(.text+0x19723): Section mismatch in reference from the function ISACVersion() to the variable .devinit.data:ISACVer
WARNING: drivers/isdn/hisax/built-in.o(.text+0x2005b): Section mismatch in reference from the function setup_avm_a1_pcmcia() to the function .devinit.text:setup_isac()

ISACVer were only used from function annotated __devinit
so add same annotation to ISACVer.
One af the fererencing functions missed __devinit so add it
and kill an additional warning.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Karsten Keil <kkeil@suse.de>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: David Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/avm_a1p.c |    3 +--
 drivers/isdn/hisax/isac.c    |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hisax/avm_a1p.c b/drivers/isdn/hisax/avm_a1p.c
index c87fa3f..3039c6d 100644
--- a/drivers/isdn/hisax/avm_a1p.c
+++ b/drivers/isdn/hisax/avm_a1p.c
@@ -213,8 +213,7 @@ AVM_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	return 0;
 }
 
-int
-setup_avm_a1_pcmcia(struct IsdnCard *card)
+int __devinit setup_avm_a1_pcmcia(struct IsdnCard *card)
 {
 	u_char model, vers;
 	struct IsdnCardState *cs = card->cs;
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 4e9f238..6ae9dde 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -27,8 +27,7 @@ static char *ISACVer[] __devinitdata =
 {"2086/2186 V1.1", "2085 B1", "2085 B2",
  "2085 V2.3"};
 
-void
-ISACVersion(struct IsdnCardState *cs, char *s)
+void __devinit ISACVersion(struct IsdnCardState *cs, char *s)
 {
 	int val;
 
-- 
1.5.4.rc3.14.g44397

