From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bcma: s&r: NULL mapped core
Date: Fri, 13 Jan 2012 08:41:20 +0100
Message-ID: <1326440480-26271-1-git-send-email-zajec5@gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64196 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab2AMHjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 02:39:42 -0500
Received: by eaal12 with SMTP id l12so64711eaa.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 23:39:41 -0800 (PST)
In-Reply-To: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/bcma/host_pci.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 443b83a..726e43d 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -237,11 +237,16 @@ static void bcma_host_pci_remove(struct pci_dev *dev)
 #ifdef CONFIG_PM
 static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t state)
 {
+	struct bcma_bus *bus = pci_get_drvdata(dev);
+
 	/* Host specific */
 	pci_save_state(dev);
 	pci_disable_device(dev);
 	pci_set_power_state(dev, pci_choose_state(dev, state));
 
+	/* Bus specific */
+	bus->mapped_core = NULL;
+
 	return 0;
 }
 
-- 
1.7.7
