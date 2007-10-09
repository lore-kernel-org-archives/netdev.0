From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] [PATCH 1/4] IPoIB: Fix unused variable warning
Date: Tue, 09 Oct 2007 15:46:13 -0700
Message-ID: <adad4vnhpoq.fsf_-_@cisco.com>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
	<20071009.135145.95506679.davem@davemloft.net>
	<adahckzhprc.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adahckzhprc.fsf@cisco.com> (Roland Dreier's message of "Tue,
	09 Oct 2007 15:44:39 -0700")
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

The conversion to use netdevice internal stats left an unused variable
in ipoib_neigh_free(), since there's no longer any reason to get
netdev_priv() in order to increment dropped packets.  Delete the
unused priv variable.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 6b1b4b2..855c9de 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -854,7 +854,6 @@ struct ipoib_neigh *ipoib_neigh_alloc(struct neighbour *neighbour)
 
 void ipoib_neigh_free(struct net_device *dev, struct ipoib_neigh *neigh)
 {
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct sk_buff *skb;
 	*to_ipoib_neigh(neigh->neighbour) = NULL;
 	while ((skb = __skb_dequeue(&neigh->queue))) {
