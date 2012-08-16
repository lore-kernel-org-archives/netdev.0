From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH net-next] sctp: fix compile issue with disabled CONFIG_NET_NS
Date: Thu, 16 Aug 2012 13:24:49 +0200
Message-ID: <20120816112449.GA17354@uweber-WS>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.sophos.com ([145.253.124.137]:55010 "EHLO mx1.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671Ab2HPLdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 07:33:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct seq_net_private has no struct net
if CONFIG_NET_NS is not enabled

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 net/sctp/proc.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 3e62ee5..d9cb2ab 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -199,7 +199,6 @@ static void * sctp_eps_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 /* Display sctp endpoints (/proc/net/sctp/eps). */
 static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 {
-	struct seq_net_private *priv = seq->private;
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 	struct sctp_endpoint *ep;
@@ -216,7 +215,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
-		if (!net_eq(sock_net(sk), priv->net))
+		if (!net_eq(sock_net(sk), seq_file_net(seq)))
 			continue;
 		seq_printf(seq, "%8pK %8pK %-3d %-3d %-4d %-5d %5d %5lu ", ep, sk,
 			   sctp_sk(sk)->type, sk->sk_state, hash,
@@ -307,7 +306,6 @@ static void * sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 /* Display sctp associations (/proc/net/sctp/assocs). */
 static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 {
-	struct seq_net_private *priv = seq->private;
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 	struct sctp_association *assoc;
@@ -324,7 +322,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 	sctp_for_each_hentry(epb, node, &head->chain) {
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
-		if (!net_eq(sock_net(sk), priv->net))
+		if (!net_eq(sock_net(sk), seq_file_net(seq)))
 			continue;
 		seq_printf(seq,
 			   "%8pK %8pK %-3d %-3d %-2d %-4d "
@@ -423,7 +421,6 @@ static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
 
 static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 {
-	struct seq_net_private *priv = seq->private;
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
 	struct sctp_association *assoc;
@@ -438,7 +435,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 	sctp_local_bh_disable();
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, node, &head->chain) {
-		if (!net_eq(sock_net(epb->sk), priv->net))
+		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
 			continue;
 		assoc = sctp_assoc(epb);
 		list_for_each_entry(tsp, &assoc->peer.transport_addr_list,
-- 
1.7.9.5
