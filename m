From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 06/10] IPoIB header file changes.
Date: Fri, 20 Jul 2007 12:03:01 +0530
Message-ID: <20070720063301.26341.70540.sendpatchset@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	sri@us.ibm.com, hadi@cyberus.ca, kaber@trash.net, mchan@broadcom.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
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

IPoIB header file changes.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 ipoib.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff -ruNp org/drivers/infiniband/ulp/ipoib/ipoib.h new/drivers/infiniband/ulp/ipoib/ipoib.h
--- org/drivers/infiniband/ulp/ipoib/ipoib.h	2007-07-20 07:49:28.000000000 +0530
+++ new/drivers/infiniband/ulp/ipoib/ipoib.h	2007-07-20 08:30:22.000000000 +0530
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
