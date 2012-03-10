From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/2] e100: enable transmit time stamping.
Date: Sat, 10 Mar 2012 18:29:43 +0100
Message-ID: <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
References: <cover.1331400160.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57944 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab2CJR35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:29:57 -0500
Received: by mail-wi0-f172.google.com with SMTP id hj6so1793497wib.1
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 09:29:56 -0800 (PST)
In-Reply-To: <cover.1331400160.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331400160.git.richardcochran@gmail.com>
References: <cover.1331400160.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Tested on an old PIII laptop with built in NIC.

Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/e100.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index e498eff..8a1ba85 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -918,6 +918,8 @@ static int e100_exec_cb(struct nic *nic, struct sk_buff *skb,
 		}
 	}
 
+	if (skb)
+		skb_tx_timestamp(skb);
 err_unlock:
 	spin_unlock_irqrestore(&nic->cb_lock, flags);
 
-- 
1.7.2.5
