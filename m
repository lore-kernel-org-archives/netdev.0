From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 4/8] s390: qeth: wrong packet length in qdio header
Date: Wed, 20 Jun 2007 12:59:14 +0200
Message-ID: <20070620105914.GD9454@de.ibm.com>
References: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:60504 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172AbXFTK6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 06:58:45 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5K9tgUW018317
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 05:55:42 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAwilk531798
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:44 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAwhML007425
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:58:44 -0400
Content-Disposition: inline
In-Reply-To: <20070620104817.GA2627@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Pavlic <fpavlic@de.ibm.com>

Packets Length in qdio header is broken when using
EDDP on Layer2 devices. This leads to skb_under_panic on receiver
system when running on z/VM GuestLAN devices.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/net/qeth_eddp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index 4640f32..70108fb 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -424,8 +424,7 @@ __qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
 		/* prepare qdio hdr */
 		if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2){
 			eddp->qh.hdr.l2.pkt_length = data_len + ETH_HLEN +
-						     eddp->nhl + eddp->thl -
-						     sizeof(struct qeth_hdr);
+						     eddp->nhl + eddp->thl;
 #ifdef CONFIG_QETH_VLAN
 			if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
 				eddp->qh.hdr.l2.pkt_length += VLAN_HLEN;
-- 
1.5.2.1

