From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH RESEND 3/3] RDMA/cxgb3: Mark qp as privileged
	based on user capabilities.
Date: Mon, 21 Jan 2008 14:42:13 -0600
Message-ID: <20080121204213.3820.12396.stgit@dell3.ogc.int>
References: <20080121204130.3820.11053.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080121204130.3820.11053.stgit@dell3.ogc.int>
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


RDMA/cxgb3: Mark qp as privileged based on user capabilities.

This is needed for zero-stag support.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_wr.h |    3 ++-
 drivers/infiniband/hw/cxgb3/iwch_qp.c |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_wr.h b/drivers/infiniband/h=
w/cxgb3/cxio_wr.h
index c84d4ac..d72b584 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_wr.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_wr.h
@@ -324,7 +324,8 @@ struct t3_genbit {
 };
=20
 enum rdma_init_wr_flags {
-	RECVS_POSTED =3D 1,
+	RECVS_POSTED =3D (1<<0),
+	PRIV_QP =3D (1<<1),
 };
=20
 union t3_wr {
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index 7681fdc..ea2cdd7 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -717,6 +717,7 @@ static int rdma_init(struct iwch_dev *rhp, struct iwc=
h_qp *qhp,
 	init_attr.qp_dma_addr =3D qhp->wq.dma_addr;
 	init_attr.qp_dma_size =3D (1UL << qhp->wq.size_log2);
 	init_attr.flags =3D rqes_posted(qhp) ? RECVS_POSTED : 0;
+	init_attr.flags |=3D capable(CAP_NET_BIND_SERVICE) ? PRIV_QP : 0;
 	init_attr.irs =3D qhp->ep->rcv_seq;
 	PDBG("%s init_attr.rq_addr 0x%x init_attr.rq_size =3D %d "
 	     "flags 0x%x qpcaps 0x%x\n", __FUNCTION__,
