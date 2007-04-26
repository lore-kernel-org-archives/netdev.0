From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 2/5] iw_cxgb3: Fail qp creation if the
	requested max_inline is too large.
Date: Thu, 26 Apr 2007 15:21:09 -0500
Message-ID: <20070426202107.24234.91018.stgit@dell3.ogc.int>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202057.24234.56383.stgit@dell3.ogc.int>
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


Fail qp creation if the requested max_inline is too large.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_wr.h       |    1 +
 drivers/infiniband/hw/cxgb3/iwch_provider.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_wr.h b/drivers/infiniband/h=
w/cxgb3/cxio_wr.h
index 90d7b89..ff7290e 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_wr.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_wr.h
@@ -38,6 +38,7 @@ #include <linux/timer.h>
 #include "firmware_exports.h"
=20
 #define T3_MAX_SGE      4
+#define T3_MAX_INLINE	64
=20
 #define Q_EMPTY(rptr,wptr) ((rptr)=3D=3D(wptr))
 #define Q_FULL(rptr,wptr,size_log2)  ( (((wptr)-(rptr))>>(size_log2)) &&=
 \
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infini=
band/hw/cxgb3/iwch_provider.c
index 24e0df0..b1128ec 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -780,6 +780,9 @@ static struct ib_qp *iwch_create_qp(stru
 	if (rqsize > T3_MAX_RQ_SIZE)
 		return ERR_PTR(-EINVAL);
=20
+	if (attrs->cap.max_inline_data > T3_MAX_INLINE)
+		return ERR_PTR(-EINVAL);
+
 	/*
 	 * NOTE: The SQ and total WQ sizes don't need to be
 	 * a power of two.  However, all the code assumes
