From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Kick the transmit watchdog timer on transmit
Date: Sun, 12 Jul 2009 18:42:32 +0900
Message-ID: <392fb48f0907120242r438411ccm5507998c3fcad877@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:60432 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbZGLJme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 05:42:34 -0400
Received: by yxe14 with SMTP id 14so2214692yxe.33
        for <netdev@vger.kernel.org>; Sun, 12 Jul 2009 02:42:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I was curious as to why sky2_tx_timeout() was being called once when
the driver started, and never again (which originally caused the crash
resolved by the previous patch).

I might be missing something, but it looks like we the transmit
watchdog needs to be kicked whenever a packet is transmitted.

This patch has had a small amount of testing, but reviewing other
drivers (e.g. net/atm/lec.c), this appears to be what is done.

thanks,

Mike

---

If we don't kick the watchdog, it always triggers.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 77fd1b9..48d58ec 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1708,6 +1708,8 @@ static int sky2_xmit_frame(struct sk_buff *skb,
struct net_device *dev)

 	sky2_put_idx(hw, txqaddr[sky2->port], sky2->tx_prod);

+	dev->trans_start = jiffies;	/* restart tx timeout */
+
 	return NETDEV_TX_OK;

 mapping_unwind:
-- 
1.5.6.5
