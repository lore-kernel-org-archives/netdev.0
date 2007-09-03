From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Ath5k panic fix
Date: Mon, 03 Sep 2007 20:35:52 +0200
Message-ID: <m3ejhfvbp3.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59253 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbXICSfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 14:35:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ath5k panics on ath_open() because sc->pdev is never set, fixed.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

--- a/drivers/net/wireless/ath5k_base.c
+++ b/drivers/net/wireless/ath5k_base.c
@@ -2295,6 +2295,7 @@ static int __devinit ath_pci_probe(struct pci_dev *pdev,
 	hw->max_rssi = 127; /* FIXME: get a real value for this. */
 	sc = hw->priv;
 	sc->hw = hw;
+	sc->pdev = pdev;
 
 	/*
 	 * Mark the device as detached to avoid processing
