From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/2] sctp: use sctp_read_[un]lock instead of read_[un]lock
Date: Mon, 20 Jan 2014 19:27:27 +0800
Message-ID: <1390217247-9408-3-git-send-email-wangweidong1@huawei.com>
References: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38632 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbaATL2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:28:09 -0500
In-Reply-To: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While we have the macros sctp_read_[un]lock, so use them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/endpointola.c |  4 ++--
 net/sctp/input.c       | 10 +++++-----
 net/sctp/proc.c        | 12 ++++++------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 6ffb6c1..68e1f91 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -342,7 +342,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	hash = sctp_assoc_hashfn(sock_net(ep->base.sk), ep->base.bind_addr.port,
 				 rport);
 	head = &sctp_assoc_hashtable[hash];
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		tmp = sctp_assoc(epb);
 		if (tmp->ep != ep || rport != tmp->peer.port)
@@ -355,7 +355,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 			break;
 		}
 	}
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 out:
 	return asoc;
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 1f4eeb4..f22669c 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -768,7 +768,7 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 
 	hash = sctp_ep_hashfn(net, ntohs(laddr->v4.sin_port));
 	head = &sctp_ep_hashtable[hash];
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		ep = sctp_ep(epb);
 		if (sctp_endpoint_is_match(ep, net, laddr))
@@ -779,7 +779,7 @@ static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
 
 hit:
 	sctp_endpoint_hold(ep);
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 	return ep;
 }
 
@@ -863,7 +863,7 @@ static struct sctp_association *__sctp_lookup_association(
 	hash = sctp_assoc_hashfn(net, ntohs(local->v4.sin_port),
 				 ntohs(peer->v4.sin_port));
 	head = &sctp_assoc_hashtable[hash];
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		asoc = sctp_assoc(epb);
 		transport = sctp_assoc_is_match(asoc, net, local, peer);
@@ -871,14 +871,14 @@ static struct sctp_association *__sctp_lookup_association(
 			goto hit;
 	}
 
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 
 	return NULL;
 
 hit:
 	*pt = transport;
 	sctp_association_hold(asoc);
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 	return asoc;
 }
 
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 63ba0bd..bbba718 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -219,7 +219,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 
 	head = &sctp_ep_hashtable[hash];
 	sctp_local_bh_disable();
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
@@ -234,7 +234,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "\n");
 	}
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 	sctp_local_bh_enable();
 
 	return 0;
@@ -327,7 +327,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 
 	head = &sctp_assoc_hashtable[hash];
 	sctp_local_bh_disable();
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		assoc = sctp_assoc(epb);
 		sk = epb->sk;
@@ -361,7 +361,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 			sk->sk_rcvbuf);
 		seq_printf(seq, "\n");
 	}
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 	sctp_local_bh_enable();
 
 	return 0;
@@ -447,7 +447,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 
 	head = &sctp_assoc_hashtable[hash];
 	sctp_local_bh_disable();
-	read_lock(&head->lock);
+	sctp_read_lock(&head->lock);
 	rcu_read_lock();
 	sctp_for_each_hentry(epb, &head->chain) {
 		if (!net_eq(sock_net(epb->sk), seq_file_net(seq)))
@@ -504,7 +504,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 	}
 
 	rcu_read_unlock();
-	read_unlock(&head->lock);
+	sctp_read_unlock(&head->lock);
 	sctp_local_bh_enable();
 
 	return 0;
-- 
1.7.12
