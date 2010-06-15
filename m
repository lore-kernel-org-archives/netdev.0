From: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Subject: [PATCH 1/2] ehea: fix delayed packet processing
Date: Tue, 15 Jun 2010 17:35:16 +0200
Message-ID: <201006151735.17258.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, tklein@linux.ibm.com,
	Andre Detsch <adetsch@br.ibm.com>, themann@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the eHEA poll function an rmb() is required. Without that some packets
on the receive queue are not seen and thus delayed until the next interrupt
is handled for the same receive queue.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
Patch created against 2.6.35-rc3

 drivers/net/ehea/ehea_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index f547894..fd890fa 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -867,6 +867,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
 		ehea_reset_cq_n1(pr->send_cq);
+		rmb();
 		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 		cqe_skb = ehea_poll_cq(pr->send_cq);
 
-- 
1.7.0
