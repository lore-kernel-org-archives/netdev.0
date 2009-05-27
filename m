From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/5] netdev: bfin_mac: fix malformed UDP packet transmission when polling with KGDB
Date: Wed, 27 May 2009 02:10:12 -0400
Message-ID: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>,
	Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32882 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759685AbZE0GKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 02:10:17 -0400
In-Reply-To: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Make sure data is really written into the registers before enabling DMA.
Otherwise, the EMAC DMA controller may transfer out a malformed packet.
This patch may also fix netperf bugs or scp bugs.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 1905532..626715c 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -688,6 +688,9 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* Make sure data is really written into registers before enabling DMA */
+	SSYNC();
+
 	/* enable this packet's dma */
 	current_tx_ptr->desc_a.config |= DMAEN;
 
-- 
1.6.3.1

