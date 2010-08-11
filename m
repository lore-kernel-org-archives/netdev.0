From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/2] pkt_sched: Check .walk and .leaf class handlers
Date: Wed, 11 Aug 2010 08:31:20 +0000
Message-ID: <20100811083120.GB10126@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Franchoze Eric <franchoze@yandex.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49993 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149Ab0HKIb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 04:31:27 -0400
Received: by mail-bw0-f46.google.com with SMTP id 3so2464316bwz.19
        for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 01:31:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Require qdisc class ops .walk and .leaf for classful qdisc in
register_qdisc(). The checks could be done later insted, but these
ops are really needed and used by most of classful qdiscs.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 8ed2f56..408eea7 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -161,7 +161,7 @@ int register_qdisc(struct Qdisc_ops *qops)
 	if (qops->cl_ops) {
 		const struct Qdisc_class_ops *cops = qops->cl_ops;
 
-		if (!(cops->get && cops->put))
+		if (!(cops->get && cops->put && cops->walk && cops->leaf))
 			goto out_einval;
 
 		if (cops->tcf_chain && !(cops->bind_tcf && cops->unbind_tcf))
