From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 4 of 39] IB/ipath - fix an indenting
 problem
Date: Thu, 29 Jun 2006 14:40:55 -0700
Message-ID: <c93c2b42d279e047acdf.1151617255@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralph Campbell <ralph.campbell@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r ebf646d10db0 -r c93c2b42d279 drivers/infiniband/hw/ipath/ipath_rc.c
--- a/drivers/infiniband/hw/ipath/ipath_rc.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_rc.c	Thu Jun 29 14:33:25 2006 -0700
@@ -1053,32 +1053,32 @@ static inline void ipath_rc_rcv_resp(str
 			goto ack_done;
 		}
 	rdma_read:
-	if (unlikely(qp->s_state != OP(RDMA_READ_REQUEST)))
-		goto ack_done;
-	if (unlikely(tlen != (hdrsize + pmtu + 4)))
-		goto ack_done;
-	if (unlikely(pmtu >= qp->s_len))
-		goto ack_done;
-	/* We got a response so update the timeout. */
-	if (unlikely(qp->s_last == qp->s_tail ||
-		     get_swqe_ptr(qp, qp->s_last)->wr.opcode !=
-		     IB_WR_RDMA_READ))
-		goto ack_done;
-	spin_lock(&dev->pending_lock);
-	if (qp->s_rnr_timeout == 0 && !list_empty(&qp->timerwait))
-		list_move_tail(&qp->timerwait,
-			       &dev->pending[dev->pending_index]);
-	spin_unlock(&dev->pending_lock);
-	/*
-	 * Update the RDMA receive state but do the copy w/o holding the
-	 * locks and blocking interrupts.  XXX Yet another place that
-	 * affects relaxed RDMA order since we don't want s_sge modified.
-	 */
-	qp->s_len -= pmtu;
-	qp->s_last_psn = psn;
-	spin_unlock_irqrestore(&qp->s_lock, flags);
-	ipath_copy_sge(&qp->s_sge, data, pmtu);
-	goto bail;
+		if (unlikely(qp->s_state != OP(RDMA_READ_REQUEST)))
+			goto ack_done;
+		if (unlikely(tlen != (hdrsize + pmtu + 4)))
+			goto ack_done;
+		if (unlikely(pmtu >= qp->s_len))
+			goto ack_done;
+		/* We got a response so update the timeout. */
+		if (unlikely(qp->s_last == qp->s_tail ||
+			     get_swqe_ptr(qp, qp->s_last)->wr.opcode !=
+			     IB_WR_RDMA_READ))
+			goto ack_done;
+		spin_lock(&dev->pending_lock);
+		if (qp->s_rnr_timeout == 0 && !list_empty(&qp->timerwait))
+			list_move_tail(&qp->timerwait,
+				       &dev->pending[dev->pending_index]);
+		spin_unlock(&dev->pending_lock);
+		/*
+		 * Update the RDMA receive state but do the copy w/o holding the
+		 * locks and blocking interrupts.  XXX Yet another place that
+		 * affects relaxed RDMA order since we don't want s_sge modified.
+		 */
+		qp->s_len -= pmtu;
+		qp->s_last_psn = psn;
+		spin_unlock_irqrestore(&qp->s_lock, flags);
+		ipath_copy_sge(&qp->s_sge, data, pmtu);
+		goto bail;
 
 	case OP(RDMA_READ_RESPONSE_LAST):
 		/* ACKs READ req. */
