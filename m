From: Luca Tettamanti <kronos.it@gmail.com>
Subject: [PATCH 2/2] atl1: zero out CMB and SBM in atl1_free_ring_resources
Date: Wed, 22 Sep 2010 22:42:31 +0200
Message-ID: <20100922204231.GA1401@nb-core2.darkstar.lan>
References: <20100922.132341.48506736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: atl1-devel@lists.sourceforge.net, jcliburn@gmail.com,
	chris.snook@gmail.com, jie.yang@atheros.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34405 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab0IVUmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 16:42:49 -0400
Received: by wwb34 with SMTP id 34so16982wwb.1
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 13:42:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100922.132341.48506736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are allocated in atl1_setup_ring_resources, zero out the pointers
in atl1_free_ring_resources (like the other resources).

Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
Acked-by: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/atlx/atl1.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index bbd6e30..c73be28 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1251,6 +1251,12 @@ static void atl1_free_ring_resources(struct atl1_adapter *adapter)
 
 	rrd_ring->desc = NULL;
 	rrd_ring->dma = 0;
+
+	adapter->cmb.dma = 0;
+	adapter->cmb.cmb = NULL;
+
+	adapter->smb.dma = 0;
+	adapter->smb.smb = NULL;
 }
 
 static void atl1_setup_mac_ctrl(struct atl1_adapter *adapter)
-- 
1.7.1
