From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 6/6] netdev: bfin_mac: avoid tx skb overflows in the tx DMA ring
Date: Tue, 19 Jan 2010 06:08:27 -0500
Message-ID: <1263899307-10627-6-git-send-email-vapier@gentoo.org>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59098 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756033Ab0ASLIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 06:08:21 -0500
In-Reply-To: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index af45f65..f5a22c8 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -920,6 +920,9 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 	u32 data_align = (unsigned long)(skb->data) & 0x3;
 	union skb_shared_tx *shtx = skb_tx(skb);
 
+	if (current_tx_ptr->next == tx_list_head)
+		return NETDEV_TX_BUSY;
+
 	current_tx_ptr->skb = skb;
 
 	if (data_align == 0x2) {
-- 
1.6.6

