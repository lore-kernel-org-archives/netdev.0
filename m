From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: off by one, try #2
Date: Wed, 11 Feb 2009 11:01:56 +0100
Message-ID: <4992A214.2040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:62368 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbZBKKB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 05:01:56 -0500
Received: by bwz5 with SMTP id 5so143631bwz.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 02:01:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better?

-------------------->8----------------8<-----------------------
With while (x++ < n) { ... } x can reach n+1.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/3c505.c        |    4 ++--
 drivers/net/irda/mcs7780.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 6124605..fb74846 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -500,9 +500,9 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 		pcb->data.raw[i++] = inb_command(dev->base_addr);
 		if (i > MAX_PCB_DATA)
 			INVALID_PCB_MSG(i);
-	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j < 20000);
+	} while ((stat & ASF_PCB_MASK) != ASF_PCB_END && j <= 20000);
 	spin_unlock_irqrestore(&adapter->lock, flags);
-	if (j >= 20000) {
+	if (j > 20000) {
 		TIMEOUT_MSG(__LINE__);
 		return false;
 	}
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 7eafdca..b4f4f19 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -585,7 +585,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 		mcs_get_reg(mcs, MCS_RESV_REG, &rval);
 	} while(cnt++ < 100 && (rval & MCS_IRINTX));
 
-	if(cnt >= 100) {
+	if(cnt > 100) {
 		IRDA_ERROR("unable to change speed\n");
 		ret = -EIO;
 		goto error;
