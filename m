From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 3/3] bnx2: Use dev_kfree_skb in Tx cleanup path
Date: Thu, 30 Apr 2015 13:58:31 -0700
Message-ID: <20150430205831.1512.61081.stgit@ahduyck-vm-fedora22>
References: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, Dept-HSGLinuxNICDev@qlogic.com,
	sony.chacko@qlogic.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951AbbD3U6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 16:58:32 -0400
In-Reply-To: <20150430205423.1512.13487.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the use of either dev_kfree_skb_any or
dev_consume_skb_any in the Tx cleanup path of this driver with
dev_kfree_skb.  There isn't any need for the "_any" version of these
functions since the NAPI cleanup context is not a hard irq context.

This change allows us to drop one function call from the clean-up path
since dev_kfree_skb_any was just calling into dev_kfree_skb in these paths
anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2b66ef3d8217..a76f21a90a4e 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2887,7 +2887,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
 
 		tx_bytes += skb->len;
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 		tx_pkt++;
 		if (tx_pkt == budget)
 			break;
