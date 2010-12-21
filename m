From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: [PATCH 1/2 -next] sundance: Wrap up acceess to ASICCtrl high word
 with a macro
Date: Tue, 21 Dec 2010 12:01:36 +0000
Message-ID: <20101221120136.GA16612@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:49213 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908Ab0LUMBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 07:01:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap up acceess to ASICCtrl high word with a macro

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/sundance.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 3ed2a67..d82944c 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -294,6 +294,9 @@ enum alta_offsets {
 	/* Aliased and bogus values! */
 	RxStatus = 0x0c,
 };
+
+#define ASIC_HI_WORD(x)	((x) + 2)
+
 enum ASICCtrl_HiWord_bit {
 	GlobalReset = 0x0001,
 	RxReset = 0x0002,
@@ -1772,10 +1775,10 @@ static int netdev_close(struct net_device *dev)
     	}
 
     	iowrite16(GlobalReset | DMAReset | FIFOReset | NetworkReset,
-			ioaddr +ASICCtrl + 2);
+			ioaddr + ASIC_HI_WORD(ASICCtrl));
 
     	for (i = 2000; i > 0; i--) {
- 		if ((ioread16(ioaddr + ASICCtrl +2) & ResetBusy) == 0)
+ 		if ((ioread16(ioaddr + ASIC_HI_WORD(ASICCtrl)) & ResetBusy) == 0)
 			break;
 		mdelay(1);
     	}
-- 
1.7.2.2

