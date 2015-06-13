From: sfeldma@gmail.com
Subject: [PATCH net-next 5/5] rocker: move port stop to 'no wait' processing
Date: Fri, 12 Jun 2015 21:35:50 -0700
Message-ID: <1434170150-63838-6-git-send-email-sfeldma@gmail.com>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37314 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbbFMEeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:07 -0400
Received: by igbsb11 with SMTP id sb11so21926309igb.0
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:34:07 -0700 (PDT)
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

rocker_port_stop can be called from atomic and non-atomic contexts.  Since
we can't test what context we're getting called in, do the processing as
'no wait', which will cover all cases.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 8430cb3..a06b93d 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4004,7 +4004,8 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE,
+				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
-- 
1.7.10.4
