From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: remove casting from function calls through
 ops structure
Date: Wed, 18 Dec 2013 17:18:55 +0800
Message-ID: <52B1687F.8080502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:16123 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3LRJU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:20:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove the unnecessary cast.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/output.c        | 4 ++--
 net/sctp/sm_sideeffect.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 6371337..f4c1bd6 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -558,7 +558,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 * Note: The works for IPv6 layer checks this bit too later
 	 * in transmission.  See IP6_ECN_flow_xmit().
 	 */
-	(*tp->af_specific->ecn_capable)(nskb->sk);
+	tp->af_specific->ecn_capable(nskb->sk);
 
 	/* Set up the IP options.  */
 	/* BUG: not implemented
@@ -592,7 +592,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	pr_debug("***sctp_transmit_packet*** skb->len:%d\n", nskb->len);
 
 	nskb->local_df = packet->ipfragok;
-	(*tp->af_specific->sctp_xmit)(nskb, tp);
+	tp->af_specific->sctp_xmit(nskb, tp);
 
 out:
 	sctp_packet_reset(packet);
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 02b7ad1..2821dcb 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1115,7 +1115,7 @@ int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
 	sctp_init_cmd_seq(&commands);
 
 	debug_pre_sfn();
-	status = (*state_fn->fn)(net, ep, asoc, subtype, event_arg, &commands);
+	status = state_fn->fn(net, ep, asoc, subtype, event_arg, &commands);
 	debug_post_sfn();
 
 	error = sctp_side_effects(event_type, subtype, state,
-- 
1.7.12
