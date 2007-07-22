From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 08/12 -Rev2] IPoIB include file changes.
Date: Sun, 22 Jul 2007 14:36:17 +0530
Message-ID: <20070722090612.7787.63282.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib.h rev2/drivers/infiniband/ulp/ipoib/ipoib.h
--- org/drivers/infiniband/ulp/ipoib/ipoib.h	2007-07-20 07:49:28.000000000 +0530
+++ rev2/drivers/infiniband/ulp/ipoib/ipoib.h	2007-07-20 16:09:45.000000000 +0530
@@ -269,8 +269,8 @@ struct ipoib_dev_priv {
 	struct ipoib_tx_buf *tx_ring;
 	unsigned             tx_head;
 	unsigned             tx_tail;
-	struct ib_sge        tx_sge;
-	struct ib_send_wr    tx_wr;
+	struct ib_sge        *tx_sge;
+	struct ib_send_wr    *tx_wr;
 
 	struct ib_wc ibwc[IPOIB_NUM_WC];
 
@@ -365,8 +365,11 @@ static inline void ipoib_put_ah(struct i
 int ipoib_open(struct net_device *dev);
 int ipoib_add_pkey_attr(struct net_device *dev);
 
+int ipoib_process_skb(struct net_device *dev, struct sk_buff *skb,
+		      struct ipoib_dev_priv *priv, int snum, int tx_index,
+		      struct ipoib_ah *address, u32 qpn);
 void ipoib_send(struct net_device *dev, struct sk_buff *skb,
-		struct ipoib_ah *address, u32 qpn);
+		struct ipoib_ah *address, u32 qpn, int num_skbs);
 void ipoib_reap_ah(struct work_struct *work);
 
 void ipoib_flush_paths(struct net_device *dev);
