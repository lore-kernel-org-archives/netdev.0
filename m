From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 3/6] iw_cxgb3: Don't count neg_adv
	abort_req_rss messages as real aborts.
Date: Wed, 27 Jun 2007 10:51:35 -0500
Message-ID: <20070627155135.24944.44327.stgit@dell3.ogc.int>
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


iw_cxgb3: Don't count neg_adv abort_req_rss messages as real aborts.

negative advice messages should _not_ count toward the 2 abort requests
needed to indicate an abort request.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 7b8d5aa..4d7c277 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1465,6 +1465,13 @@ static int peer_abort(struct t3cdev *tde
 	int ret;
 	int state;
=20
+	if (is_neg_adv_abort(req->status)) {
+		PDBG("%s neg_adv_abort ep %p tid %d\n", __FUNCTION__, ep,
+		     ep->hwtid);
+		t3_l2t_send_event(ep->com.tdev, ep->l2t);
+		return CPL_RET_BUF_DONE;
+	}
+
 	/*
 	 * We get 2 peer aborts from the HW.  The first one must
 	 * be ignored except for scribbling that we need one more.
@@ -1474,13 +1481,6 @@ static int peer_abort(struct t3cdev *tde
 		return CPL_RET_BUF_DONE;
 	}
=20
-	if (is_neg_adv_abort(req->status)) {
-		PDBG("%s neg_adv_abort ep %p tid %d\n", __FUNCTION__, ep,
-		     ep->hwtid);
-		t3_l2t_send_event(ep->com.tdev, ep->l2t);
-		return CPL_RET_BUF_DONE;
-	}
-
 	state =3D state_read(&ep->com);
 	PDBG("%s ep %p state %u\n", __FUNCTION__, ep, state);
 	switch (state) {
