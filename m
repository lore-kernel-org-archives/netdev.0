From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 18/30] bridge: Introduce br_send_bpdu_finish
Date: Tue, 15 Sep 2015 20:04:06 -0500
Message-ID: <1442365458-16349-18-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39418 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbbIPBNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:44 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function dev_queue_xmit_skb_sk is unncessary and very confusing.
Introduce br_send_bpdu_finish to remove the need for dev_queue_xmit_skb_sk,
and have br_send_bpdu_finish call dev_queue_xmit.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/bridge/br_stp_bpdu.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 534fc4cd263e..3017a396cdef 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -30,6 +30,11 @@
 
 #define LLC_RESERVE sizeof(struct llc_pdu_un)
 
+static int br_send_bpdu_finish(struct sock *sk, struct sk_buff *skb)
+{
+	return dev_queue_xmit(skb);
+}
+
 static void br_send_bpdu(struct net_bridge_port *p,
 			 const unsigned char *data, int length)
 {
@@ -56,7 +61,7 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
 		NULL, skb->dev,
-		dev_queue_xmit_sk);
+		br_send_bpdu_finish);
 }
 
 static inline void br_set_ticks(unsigned char *dest, int j)
-- 
2.2.1
