From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 2/6] cxgb4vf: fix bug in Generic Receive Offload
Date: Thu, 11 Nov 2010 11:06:49 -0800
Message-ID: <1289502413-9895-3-git-send-email-leedom@chelsio.com>
References: <1289502413-9895-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27702 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab0KKTHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 14:07:00 -0500
In-Reply-To: <1289502413-9895-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix botch in Generic Receive Offload (the Packet Gather List Total length
field wasn't being initialized).

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/sge.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index f10864d..6a6e18b 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1679,6 +1679,7 @@ int process_responses(struct sge_rspq *rspq, int budget)
 				}
 				len = RSPD_LEN(len);
 			}
+			gl.tot_len = len;
 
 			/*
 			 * Gather packet fragments.
-- 
1.7.0.4

