From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/3] netxen: fix vlan tso case
Date: Wed,  5 Aug 2009 10:34:07 -0700
Message-ID: <1249493649-26336-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:31975 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1750706AbZHEReL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 13:34:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the calculation of remaining header length in TSO
over vlan device case. This was inadvertently missed
out in patch 028afe719855a157e32450c ("netxen: add vlan
tx acceleration support").

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 40549a0..c91e022 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1450,7 +1450,7 @@ netxen_tso_check(struct net_device *netdev,
 		skb_copy_from_linear_data_offset(skb, 12,
 				(char *)vh + 16, copy_len - 16);
 
-		copied = copy_len;
+		copied = copy_len - VLAN_HLEN;
 		offset = 0;
 
 		producer = get_next_index(producer, tx_ring->num_desc);
-- 
1.6.0.2

