From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 2/2] bna: fix memory leak during RX path cleanup
Date: Thu, 14 Apr 2011 11:05:19 -0700
Message-ID: <1302804319-15677-2-git-send-email-rmody@brocade.com>
References: <1302804319-15677-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53587 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933729Ab1DNSGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 14:06:16 -0400
In-Reply-To: <1302804319-15677-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory leak was caused by unintentional assignment of the Rx path
destroy callback function pointer to NULL just after correct
initialization.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index b9f2534..e588511 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -1837,7 +1837,6 @@ bnad_setup_rx(struct bnad *bnad, uint rx_id)
 	/* Initialize the Rx event handlers */
 	rx_cbfn.rcb_setup_cbfn = bnad_cb_rcb_setup;
 	rx_cbfn.rcb_destroy_cbfn = bnad_cb_rcb_destroy;
-	rx_cbfn.rcb_destroy_cbfn = NULL;
 	rx_cbfn.ccb_setup_cbfn = bnad_cb_ccb_setup;
 	rx_cbfn.ccb_destroy_cbfn = bnad_cb_ccb_destroy;
 	rx_cbfn.rx_cleanup_cbfn = bnad_cb_rx_cleanup;
-- 
1.7.1

