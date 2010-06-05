From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH] 8139too: fix buffer overrun in rtl8139_init_board
Date: Sat, 5 Jun 2010 09:45:49 +0000
Message-ID: <20100605094549.GA11559@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:39944 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932681Ab0FEJq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jun 2010 05:46:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix rtl_chip_info buffer overrun when we can't identify the chip.
(i = ARRAY_SIZE (rtl_chip_info) in this case)

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
drivers/net/8139too.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index cc7d462..149253d 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -860,6 +860,7 @@ retry:
 		}
 
 	/* if unknown chip, assume array element #0, original RTL-8139 in this case */
+	i = 0;
 	dev_dbg(&pdev->dev, "unknown chip version, assuming RTL-8139\n");
 	dev_dbg(&pdev->dev, "TxConfig = 0x%x\n", RTL_R32 (TxConfig));
 	tp->chipset = 0;
