From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] igb: only use vlan_gro_receive if vlans are registered
Date: Tue, 23 Mar 2010 21:35:18 -0700
Message-ID: <20100324043517.32036.81274.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:46650
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751272Ab0CXEfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 00:35:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that vlan_gro_receive is only used if vlans have been
registered to the adapter structure.  Previously we were just sending all vlan
tagged frames in via this function but this results in a null pointer
dereference when vlans are not registered.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e72760c..01c65c7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5102,7 +5102,7 @@ static void igb_receive_skb(struct igb_q_vector *q_vector,
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 
-	if (vlan_tag)
+	if (vlan_tag && adapter->vlgrp)
 		vlan_gro_receive(&q_vector->napi, adapter->vlgrp,
 		                 vlan_tag, skb);
 	else

