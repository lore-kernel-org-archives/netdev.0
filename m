From: akpm@linux-foundation.org
Subject: [patch 2/4] hardware/mISDN/mISDNinfineon.c: bail out of loop on error
Date: Tue, 02 Feb 2010 14:43:45 -0800
Message-ID: <201002022243.o12MhjvM019218@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	darrenrjenkins@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41238 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754630Ab0BBWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Darren Jenkins <darrenrjenkins@gmail.com>

If setup_instance() fails we kfree() the card, and then use it in the next
loop iteration.  So lets bail out of the loop instead.

Coverity CID: 13357

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/mISDNinfineon.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/isdn/hardware/mISDN/mISDNinfineon.c~hardware-misdn-misdninfineonc-bail-out-of-loop-on-error drivers/isdn/hardware/mISDN/mISDNinfineon.c
--- a/drivers/isdn/hardware/mISDN/mISDNinfineon.c~hardware-misdn-misdninfineonc-bail-out-of-loop-on-error
+++ a/drivers/isdn/hardware/mISDN/mISDNinfineon.c
@@ -1133,6 +1133,7 @@ inf_probe(struct pci_dev *pdev, const st
 			if (err) {
 				kfree(sc);
 				release_card(card);
+				break;
 			} else
 				card->sc[i - 1] = sc;
 		}
_
