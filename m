From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 1/2] ixgbe: change ndo_xdp_xmit return code on xmit errors
Date: Thu, 17 Aug 2017 18:22:32 +0200
Message-ID: <150298695248.6608.8521160586255097145.stgit@firesoul>
References: <150298692691.6608.11908184719252996949.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47648 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdHQQWf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 12:22:35 -0400
In-Reply-To: <150298692691.6608.11908184719252996949.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use errno -ENOSPC ("No space left on device") when the XDP xmit
have no space left on the TX ring buffer, instead of -ENOMEM.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f9fd8d8f1bef..017cd5e85c97 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9860,7 +9860,7 @@ static int ixgbe_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
 
 	err = ixgbe_xmit_xdp_ring(adapter, xdp);
 	if (err != IXGBE_XDP_TX)
-		return -ENOMEM;
+		return -ENOSPC;
 
 	return 0;
 }
