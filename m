From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] cxgb4vf: function namespace cleanup
Date: Fri, 15 Oct 2010 15:43:12 -0700
Message-ID: <20101015224523.727651263@vyatta.com>
References: <20101015224309.179898823@vyatta.com>
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60763 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab0JOXXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 19:23:42 -0400
Content-Disposition: inline; filename=cxgb4vf-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Where possible make functions local.
Compile tested only

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/cxgb4vf/sge.c         |    6 +++---
 drivers/net/cxgb4vf/t4vf_common.h |    1 -
 drivers/net/cxgb4vf/t4vf_hw.c     |    4 ++--
 3 files changed, 5 insertions(+), 6 deletions(-)

--- a/drivers/net/cxgb4vf/sge.c	2010-10-15 13:35:37.841741143 -0700
+++ b/drivers/net/cxgb4vf/sge.c	2010-10-15 13:37:26.753998981 -0700
@@ -1361,7 +1361,7 @@ out_free:
  *	Releases the pages of a packet gather list.  We do not own the last
  *	page on the list and do not free it.
  */
-void t4vf_pktgl_free(const struct pkt_gl *gl)
+static void t4vf_pktgl_free(const struct pkt_gl *gl)
 {
 	int frag;
 
@@ -1636,7 +1636,7 @@ static inline void rspq_next(struct sge_
  *	on this queue.  If the system is under memory shortage use a fairly
  *	long delay to help recovery.
  */
-int process_responses(struct sge_rspq *rspq, int budget)
+static int process_responses(struct sge_rspq *rspq, int budget)
 {
 	struct sge_eth_rxq *rxq = container_of(rspq, struct sge_eth_rxq, rspq);
 	int budget_left = budget;
@@ -1888,7 +1888,7 @@ static unsigned int process_intrq(struct
  * The MSI interrupt handler handles data events from SGE response queues as
  * well as error and other async events as they all use the same MSI vector.
  */
-irqreturn_t t4vf_intr_msi(int irq, void *cookie)
+static irqreturn_t t4vf_intr_msi(int irq, void *cookie)
 {
 	struct adapter *adapter = cookie;
 
--- a/drivers/net/cxgb4vf/t4vf_common.h	2010-10-15 13:38:12.555553059 -0700
+++ b/drivers/net/cxgb4vf/t4vf_common.h	2010-10-15 13:38:30.716055176 -0700
@@ -235,7 +235,6 @@ static inline int t4vf_wr_mbox_ns(struct
 int __devinit t4vf_wait_dev_ready(struct adapter *);
 int __devinit t4vf_port_init(struct adapter *, int);
 
-int t4vf_query_params(struct adapter *, unsigned int, const u32 *, u32 *);
 int t4vf_set_params(struct adapter *, unsigned int, const u32 *, const u32 *);
 
 int t4vf_get_sge_params(struct adapter *);
--- a/drivers/net/cxgb4vf/t4vf_hw.c	2010-10-15 13:35:44.638006598 -0700
+++ b/drivers/net/cxgb4vf/t4vf_hw.c	2010-10-15 13:38:04.503330665 -0700
@@ -335,8 +335,8 @@ int __devinit t4vf_port_init(struct adap
  *	Reads the values of firmware or device parameters.  Up to 7 parameters
  *	can be queried at once.
  */
-int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
-		      const u32 *params, u32 *vals)
+static int t4vf_query_params(struct adapter *adapter, unsigned int nparams,
+			     const u32 *params, u32 *vals)
 {
 	int i, ret;
 	struct fw_params_cmd cmd, rpl;


