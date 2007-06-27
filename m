From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 4/6] iw_cxgb3: ctrl-qp init/clear shouldn't set
	the gen bit.
Date: Wed, 27 Jun 2007 10:51:40 -0500
Message-ID: <20070627155140.24944.61647.stgit@dell3.ogc.int>
References: <20070627155119.24944.44172.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070627155119.24944.44172.stgit@dell3.ogc.int>
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


iw_cxgb3: ctrl-qp init/clear shouldn't set the gen bit.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/=
hw/cxgb3/cxio_hal.c
index 215bbe5..1518b41 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -144,7 +144,7 @@ static int cxio_hal_clear_qp_ctx(struct=20
 	}
 	wqe =3D (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof(*wqe));
-	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 3, 1, qpid, 7);
+	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 3, 0, qpid, 7);
 	wqe->flags =3D cpu_to_be32(MODQP_WRITE_EC);
 	sge_cmd =3D qpid << 8 | 3;
 	wqe->sge_cmd =3D cpu_to_be64(sge_cmd);
@@ -548,7 +548,7 @@ static int cxio_hal_init_ctrl_qp(struct=20
 			V_EC_UP_TOKEN(T3_CTL_QP_TID) | F_EC_VALID)) << 32;
 	wqe =3D (struct t3_modify_qp_wr *) skb_put(skb, sizeof(*wqe));
 	memset(wqe, 0, sizeof(*wqe));
-	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 0, 1,
+	build_fw_riwrh((struct fw_riwrh *) wqe, T3_WR_QP_MOD, 0, 0,
 		       T3_CTL_QP_TID, 7);
 	wqe->flags =3D cpu_to_be32(MODQP_WRITE_EC);
 	sge_cmd =3D (3ULL << 56) | FW_RI_SGEEC_START << 8 | 3;
