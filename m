From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 5/10 Rev4] [IPoIB] Header file changes
Date: Wed, 22 Aug 2007 14:00:13 +0530
Message-ID: <20070822083013.11964.62026.sendpatchset@localhost.localdomain>
References: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:38463 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124AbXHVI2p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 04:28:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7M8Sin7015281
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:44 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7M8SiAf362716
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:44 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7M8Sfok006655
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 04:28:44 -0400
In-Reply-To: <20070822082839.11964.63503.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB header file changes to use batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib.h new/drivers/infiniband/ulp/ipoib/ipoib.h
--- org/drivers/infiniband/ulp/ipoib/ipoib.h	2007-08-20 14:26:26.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib.h	2007-08-22 08:33:51.000000000 +0530
@@ -271,8 +271,8 @@ struct ipoib_dev_priv {
 	struct ipoib_tx_buf *tx_ring;
 	unsigned             tx_head;
 	unsigned             tx_tail;
-	struct ib_sge        tx_sge;
-	struct ib_send_wr    tx_wr;
+	struct ib_sge        *tx_sge;
+	struct ib_send_wr    *tx_wr;
 
 	struct ib_wc ibwc[IPOIB_NUM_WC];
 
@@ -367,8 +367,11 @@ static inline void ipoib_put_ah(struct i
 int ipoib_open(struct net_device *dev);
 int ipoib_add_pkey_attr(struct net_device *dev);
 
+int ipoib_process_skb(struct net_device *dev, struct sk_buff *skb,
+		      struct ipoib_dev_priv *priv, struct ipoib_ah *address,
+		      u32 qpn, int wr_num);
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 qpn);
+		struct ipoib_ah *address, u32 qpn, int num_skbs);
 void ipoib_reap_ah(struct work_struct *work);
 
 void ipoib_flush_paths(struct net_device *dev);
