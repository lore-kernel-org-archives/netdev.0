From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 5/10 REV5] [IPoIB] Header file changes
Date: Fri, 14 Sep 2007 14:32:46 +0530
Message-ID: <20070914090246.17589.74932.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, xma@us.ibm.com, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, hadi@cyberus.ca,
	kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36852 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895AbXINJAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 05:00:51 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8E92Hk8012165
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:02:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8E90odi691762
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:00:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8E90lk2024434
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 05:00:50 -0400
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPoIB header file changes to use batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib.h new/drivers/infiniband/ulp/ipoib/ipoib.h
--- org/drivers/infiniband/ulp/ipoib/ipoib.h	2007-09-13 09:10:58.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib.h	2007-09-14 10:25:36.000000000 +0530
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
