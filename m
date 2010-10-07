From: Oskar Schirmer <oskar@linutronix.de>
Subject: [PATCH] net/fec: carrier off initially to avoid root mount failure
Date: Thu,  7 Oct 2010 14:30:30 +0200
Message-ID: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
Cc: Dan Malek <dan@embeddedalley.com>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@linutronix.de>,
	Oskar Schirmer <oskar@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:57214 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760392Ab0JGMag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 08:30:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

with hardware slow in negotiation, the system did freeze
while trying to mount root on nfs at boot time.

the link state has not been initialised so network stack
tried to start transmission right away. this caused instant
retries, as the driver solely stated business upon link down,
rendering the system unusable.

notify carrier off initially to prevent transmission until
phylib will report link up.

Signed-off-by: Oskar Schirmer <oskar@linutronix.de>
---
 drivers/net/fec.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 768b840..e83f67d 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1311,6 +1311,9 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_mii_init;
 
+	/* Carrier starts down, phylib will bring it up */
+	netif_carrier_off(ndev);
+
 	ret = register_netdev(ndev);
 	if (ret)
 		goto failed_register;
-- 
1.7.0.4

