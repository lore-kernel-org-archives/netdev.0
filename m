From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.21 2/6] iw_cxgb3: Move QP to error on destroy if the state is IDLE.
Date: Thu, 01 Mar 2007 16:50:40 -0600
Message-ID: <20070301225040.2373.75346.stgit@dell3.ogc.int>
References: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161098AbXCAWvs@vger.kernel.org>
In-Reply-To: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Move QP to error on destroy if the state is IDLE.

Change iwch_destroy_qp() to always move the QP to ERROR and let
iwch_modify_qp() decide what to do.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index 9947a14..a56c902 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -736,10 +736,8 @@ static int iwch_destroy_qp(struct ib_qp 
 	qhp = to_iwch_qp(ib_qp);
 	rhp = qhp->rhp;
 
-	if (qhp->attr.state == IWCH_QP_STATE_RTS) {
-		attrs.next_state = IWCH_QP_STATE_ERROR;
-		iwch_modify_qp(rhp, qhp, IWCH_QP_ATTR_NEXT_STATE, &attrs, 0);
-	}
+	attrs.next_state = IWCH_QP_STATE_ERROR;
+	iwch_modify_qp(rhp, qhp, IWCH_QP_ATTR_NEXT_STATE, &attrs, 0);
 	wait_event(qhp->wait, !qhp->ep);
 
 	remove_handle(rhp, &rhp->qpidr, qhp->wq.qpid);
