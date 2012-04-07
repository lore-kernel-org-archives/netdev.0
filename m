From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 1/1] e100: enable transmit time stamping.
Date: Sat,  7 Apr 2012 14:49:46 +0200
Message-ID: <d9af1ff17599cb3e3fa6e1163a417727c3fa09fc.1333802621.git.richardcochran@gmail.com>
References: <1333532088.3046.22.camel@jtkirshe-mobl>
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34079 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753740Ab2DGMuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 08:50:03 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2846715wgb.1
        for <netdev@vger.kernel.org>; Sat, 07 Apr 2012 05:50:02 -0700 (PDT)
In-Reply-To: <1333532088.3046.22.camel@jtkirshe-mobl>
In-Reply-To: <cover.1333802620.git.richardcochran@gmail.com>
References: <cover.1333802620.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index e498eff..872e17c 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1759,6 +1759,7 @@ static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
 	/* check for mapping failure? */
 	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
+	skb_tx_timestamp(skb);
 }
 
 static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
-- 
1.7.2.5
