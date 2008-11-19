From: Patrick McHardy <kaber@trash.net>
Subject: pkt_sched: fix missing check for packet overrun in qdisc_dump_stab()
Date: Wed, 19 Nov 2008 14:20:51 +0100
Message-ID: <492412B3.8050300@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080709060703020301000008"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63626 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbYKSNVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 08:21:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080709060703020301000008
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080709060703020301000008
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit c870f95c8c5c40d2c38970246ed737b8264f0b0e
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 19 14:19:11 2008 +0100

    pkt_sched: fix missing check for packet overrun in qdisc_dump_stab()
    
    nla_nest_start() might return NULL, causing a NULL pointer dereference.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 5bcef13..1ef25e6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -422,6 +422,8 @@ static int qdisc_dump_stab(struct sk_buff *skb, struct qdisc_size_table *stab)
 	struct nlattr *nest;
 
 	nest = nla_nest_start(skb, TCA_STAB);
+	if (nest == NULL)
+		goto nla_put_failure;
 	NLA_PUT(skb, TCA_STAB_BASE, sizeof(stab->szopts), &stab->szopts);
 	nla_nest_end(skb, nest);
 

--------------080709060703020301000008--
