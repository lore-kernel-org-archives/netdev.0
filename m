From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/7][ATM]: Replacing kmalloc/memset combination with kzalloc.
Date: Mon, 16 Jul 2007 12:29:43 -0400
Message-ID: <200707161629.l6GGTh3U009254@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759518AbXGPREo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: Replacing kmalloc/memset combination with kzalloc.

Signed-off-by: vignesh babu <vignesh.babu@wipro.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit ffc2850a65ef863fe52650e5e1bc7ac3e098bbb8
tree 1e66e6f29dbda236b826cfdd6ce1b053d15224d9
parent 99d24edeb6abc6ca3a0d0fbdb83c664c04403c8c
author vignesh babu <vignesh.babu@wipro.com> Wed, 11 Jul 2007 12:15:49 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 11 Jul 2007 12:15:49 -0400

 net/sched/sch_atm.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 54b92d2..2df38bb 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -292,13 +292,12 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		}
 	}
 	DPRINTK("atm_tc_change: new id %x\n",classid);
-	flow = kmalloc(sizeof(struct atm_flow_data)+hdr_len,GFP_KERNEL);
+	flow = kzalloc(sizeof(struct atm_flow_data)+hdr_len, GFP_KERNEL);
 	DPRINTK("atm_tc_change: flow %p\n",flow);
 	if (!flow) {
 		error = -ENOBUFS;
 		goto err_out;
 	}
-	memset(flow,0,sizeof(*flow));
 	flow->filter_list = NULL;
 	if (!(flow->q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops,classid)))
 		flow->q = &noop_qdisc;
