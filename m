From: Michal Ostrowski <mostrows@earthlink.net>
Subject: [PATCH 1/4] PPPoE: miscellaneous smaller cleanups
Date: Tue, 13 Mar 2007 09:09:32 -0500
Message-ID: <11737949753580-git-send-email-mostrows@earthlink.net>
Cc: Florian Zumbiehl <florz@florz.de>
To: mostrows@watson.ibm.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:47125 "EHLO
	igw2.watson.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965753AbXCMOHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2007 10:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

below is a patch that just removes dead code/initializers without any
effect (first access is an assignment) that I stumbled accross while
reading the source.

Signed-off-by: Florian Zumbiehl <florz@florz.de>
Acked-by: Michal Ostrowski <mostrows@earthlink.net>
---
 drivers/net/pppoe.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index ebfa296..ec4e67d 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -207,7 +207,7 @@ static inline struct pppox_sock *get_item(unsigned long sid,
 
 static inline struct pppox_sock *get_item_by_addr(struct sockaddr_pppox *sp)
 {
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	int ifindex;
 
 	dev = dev_get_by_name(sp->sa_addr.pppoe.dev);
@@ -222,9 +222,6 @@ static inline int set_item(struct pppox_sock *po)
 {
 	int i;
 
-	if (!po)
-		return -EINVAL;
-
 	write_lock_bh(&pppoe_hash_lock);
 	i = __set_item(po);
 	write_unlock_bh(&pppoe_hash_lock);
@@ -344,7 +341,7 @@ static struct notifier_block pppoe_notifier = {
 static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 {
 	struct pppox_sock *po = pppox_sk(sk);
-	struct pppox_sock *relay_po = NULL;
+	struct pppox_sock *relay_po;
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
@@ -514,7 +511,6 @@ static int pppoe_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po;
-	int error = 0;
 
 	if (!sk)
 		return 0;
@@ -543,7 +539,7 @@ static int pppoe_release(struct socket *sock)
 	skb_queue_purge(&sk->sk_receive_queue);
 	sock_put(sk);
 
-	return error;
+	return 0;
 }
 
 
@@ -762,10 +758,10 @@ static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
 static int pppoe_sendmsg(struct kiocb *iocb, struct socket *sock,
 		  struct msghdr *m, size_t total_len)
 {
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po = pppox_sk(sk);
-	int error = 0;
+	int error;
 	struct pppoe_hdr hdr;
 	struct pppoe_hdr *ph;
 	struct net_device *dev;
@@ -929,10 +925,10 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 		  struct msghdr *m, size_t total_len, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct sk_buff *skb = NULL;
+	struct sk_buff *skb;
 	int error = 0;
 	int len;
-	struct pppoe_hdr *ph = NULL;
+	struct pppoe_hdr *ph;
 
 	if (sk->sk_state & PPPOX_BOUND) {
 		error = -EIO;
@@ -949,7 +945,6 @@ static int pppoe_recvmsg(struct kiocb *iocb, struct socket *sock,
 	m->msg_namelen = 0;
 
 	if (skb) {
-		error = 0;
 		ph = (struct pppoe_hdr *) skb->nh.raw;
 		len = ntohs(ph->length);
 
@@ -991,7 +986,7 @@ out:
 
 static __inline__ struct pppox_sock *pppoe_get_idx(loff_t pos)
 {
-	struct pppox_sock *po = NULL;
+	struct pppox_sock *po;
 	int i = 0;
 
 	for (; i < PPPOE_HASH_SIZE; i++) {
-- 
1.5.0.g78e90

