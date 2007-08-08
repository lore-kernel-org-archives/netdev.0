From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 5/9 Rev3] [IPoIB] Header file changes
Date: Wed, 08 Aug 2007 15:02:06 +0530
Message-ID: <20070808093206.15396.44008.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, hadi@cyberus.ca, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru, kaber@trash.net, shemminger@linux-foundation.org,
	davem@davemloft.net, sri@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
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

IPoIB header file changes to use batching.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib.h |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff -ruNp ORG/drivers/infiniband/ulp/ipoib/ipoib.h NEW/drivers/infiniband/ulp/ipoib/ipoib.h
--- ORG/drivers/infiniband/ulp/ipoib/ipoib.h	2007-07-12 08:55:06.000000000 +0530
+++ NEW/drivers/infiniband/ulp/ipoib/ipoib.h	2007-08-07 13:11:19.000000000 +0530
@@ -266,11 +266,13 @@ struct ipoib_dev_priv {
 	struct ipoib_rx_buf *rx_ring;
 
 	spinlock_t           tx_lock;
+	spinlock_t           comp_lock;		/* to handle parallel WC's */
 	struct ipoib_tx_buf *tx_ring;
 	unsigned             tx_head;
 	unsigned             tx_tail;
-	struct ib_sge        tx_sge;
-	struct ib_send_wr    tx_wr;
+	unsigned             tx_prev_tail;	/* to handle parallel WC's */
+	struct ib_sge        *tx_sge;
+	struct ib_send_wr    *tx_wr;
 
 	struct ib_wc ibwc[IPOIB_NUM_WC];
 
@@ -365,8 +367,11 @@ static inline void ipoib_put_ah(struct i
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
