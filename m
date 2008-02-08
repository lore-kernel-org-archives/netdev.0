From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] isdn: fix section mismatch warnings from hisax_cs_setup_card
Date: Fri,  8 Feb 2008 21:00:01 +0100
Message-ID: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Cc: Sam Ravnborg <sam@ravnborg.org>, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:49579 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759434AbYBHT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 14:59:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following warnings:
WARNING: drivers/isdn/hisax/built-in.o(.text+0x722): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_teles3()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x72c): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_s0box()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x736): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_telespci()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x747): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_avm_pcipnp()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x74e): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_elsa()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x755): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_diva()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x75c): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_sedlbauer()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x763): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_netjet_s()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x76a): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_hfcpci()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x771): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_hfcsx()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x778): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_niccy()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x77f): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_bkm_a4t()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x786): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_sct_quadro()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x78d): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_gazel()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x794): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_w6692()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x79b): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_netjet_u()
WARNING: drivers/isdn/hisax/built-in.o(.text+0x7a2): Section mismatch in reference from the function hisax_cs_setup_card() to the function .devinit.text:setup_enternow_pci()

checkcard() are the only user of hisax_cs_setup_card().
And checkcard is only used during init or when hot plugging
ISDN devices. So annotate hisax_cs_setup_card() with __devinit.
checkcard() is used by exported functions so it cannot be
annotated __devinit. Annotate it with __ref so modpost
ignore references to _devinit section.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Karsten Keil <kkeil@suse.de>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: David Miller <davem@davemloft.net>
---
---
 drivers/isdn/hisax/config.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index 97097ef..a0ee43c 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -847,7 +847,7 @@ static int init_card(struct IsdnCardState *cs)
 	return 3;
 }
 
-static int hisax_cs_setup_card(struct IsdnCard *card)
+static int __devinit hisax_cs_setup_card(struct IsdnCard *card)
 {
 	int ret;
 
@@ -1166,7 +1166,10 @@ outf_cs:
 	return 0;
 }
 
-static int checkcard(int cardnr, char *id, int *busy_flag, struct module *lockowner)
+/* Used from an exported function but calls __devinit functions.
+ * Tell modpost not to warn (__ref)
+ */
+static int __ref checkcard(int cardnr, char *id, int *busy_flag, struct module *lockowner)
 {
 	int ret;
 	struct IsdnCard *card = cards + cardnr;
-- 
1.5.4.rc3.14.g44397

