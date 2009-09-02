From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tc: Fix unitialized kernel memory leak
Date: Wed, 02 Sep 2009 14:40:09 +0200
Message-ID: <4A9E67A9.7090205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40822 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbZIBMkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 08:40:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Three bytes of uninitialized kernel memory are currently leaked to user

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 24d17ce..fdb694e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1456,6 +1456,8 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
+	tcm->tcm__pad1 = 0;
+	tcm->tcm__pad2 = 0;
 	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
