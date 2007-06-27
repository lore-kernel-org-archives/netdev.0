From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2/6] iw_cxgb3: TERMINATE WRs can hang the tx
	ofld queue.
Date: Wed, 27 Jun 2007 10:51:30 -0500
Message-ID: <20070627155130.24944.55771.stgit@dell3.ogc.int>
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


iw_cxgb3: TERMINATE WRs can hang the tx ofld queue.

Don't set the gen bits nor length bits in the terminate wr.  This is
done by the LLD driver.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_qp.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index 679b7c1..dd89b6b 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -628,9 +628,9 @@ int iwch_post_terminate(struct iwch_qp *
 	/* immediate data starts here. */
 	term =3D (struct terminate_message *)wqe->send.sgl;
 	build_term_codes(rsp_msg, &term->layer_etype, &term->ecode);
-	build_fw_riwrh((void *)wqe, T3_WR_SEND,
-		       T3_COMPLETION_FLAG | T3_NOTIFY_FLAG, 1,
-		       qhp->ep->hwtid, 5);
+	wqe->send.wrh.op_seop_flags =3D cpu_to_be32(V_FW_RIWR_OP(T3_WR_SEND) |
+			 V_FW_RIWR_FLAGS(T3_COMPLETION_FLAG | T3_NOTIFY_FLAG));
+	wqe->send.wrh.gen_tid_len =3D cpu_to_be32(V_FW_RIWR_TID(qhp->ep->hwtid)=
);
 	skb->priority =3D CPL_PRIORITY_DATA;
 	return cxgb3_ofld_send(qhp->rhp->rdev.t3cdev_p, skb);
 }
