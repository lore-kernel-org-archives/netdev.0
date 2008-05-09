From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.26] RDMA/cxgb3: Wrap the software sq ptr as
	needed on flush.
Date: Fri, 09 May 2008 15:19:02 -0500
Message-ID: <20080509201902.13077.53047.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
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


cxio_flush_sq() was failing to wrap around the sw-sq causing garbage
completion entries on a flush operation.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/=
hw/cxgb3/cxio_hal.c
index 5fd8506..20a6326 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -405,11 +405,11 @@ int cxio_flush_sq(struct t3_wq *wq, struct t3_cq *c=
q, int count)
 	struct t3_swsq *sqp =3D wq->sq + Q_PTR2IDX(wq->sq_rptr, wq->sq_size_log=
2);
=20
 	ptr =3D wq->sq_rptr + count;
-	sqp +=3D count;
+	sqp =3D wq->sq + Q_PTR2IDX(ptr, wq->sq_size_log2);
 	while (ptr !=3D wq->sq_wptr) {
 		insert_sq_cqe(wq, cq, sqp);
-		sqp++;
 		ptr++;
+		sqp =3D wq->sq + Q_PTR2IDX(ptr, wq->sq_size_log2);
 		flushed++;
 	}
 	return flushed;
