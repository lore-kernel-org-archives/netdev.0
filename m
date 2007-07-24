From: Tom Tucker <tom@opengridcomputing.com>
Subject: [ofa-general] [PATCH] amso1100: QP init bug in amso driver
Date: Tue, 24 Jul 2007 14:31:52 -0500
Message-ID: <1185305512.20489.6.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
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

Roland:

The guys at UNH found this and fixed it. I'm surprised no
one has hit this before. I guess it only breaks when the 
refcount on the QP is non-zero.

Initialize the wait_queue_head_t in the c2_qp structure.

Signed-off-by: Ethan Burns <eaburns@iol.unh.edu>
Acked-by: Tom Tucker <tom@opengridcomputing.com>

---
 drivers/infiniband/hw/amso1100/c2_qp.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_qp.c b/drivers/infiniband/hw/amso1100/c2_qp.c
index 420c138..01d0786 100644
--- a/drivers/infiniband/hw/amso1100/c2_qp.c
+++ b/drivers/infiniband/hw/amso1100/c2_qp.c
@@ -506,6 +506,7 @@ int c2_alloc_qp(struct c2_dev *c2dev,
 	qp->send_sgl_depth = qp_attrs->cap.max_send_sge;
 	qp->rdma_write_sgl_depth = qp_attrs->cap.max_send_sge;
 	qp->recv_sgl_depth = qp_attrs->cap.max_recv_sge;
+	init_waitqueue_head(&qp->wait);
 
 	/* Initialize the SQ MQ */
 	q_size = be32_to_cpu(reply->sq_depth);
