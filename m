From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net_sched: info leak in atm_tc_dump_class()
Date: Tue, 30 Jul 2013 13:23:39 +0300
Message-ID: <20130730102339.GA14869@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "pvc" struct has a hole after pvc.sap_family which is not cleared.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index ca8e0a5..1f9c314 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -605,6 +605,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 		struct sockaddr_atmpvc pvc;
 		int state;
 
+		memset(&pvc, 0, sizeof(pvc));
 		pvc.sap_family = AF_ATMPVC;
 		pvc.sap_addr.itf = flow->vcc->dev ? flow->vcc->dev->number : -1;
 		pvc.sap_addr.vpi = flow->vcc->vpi;
