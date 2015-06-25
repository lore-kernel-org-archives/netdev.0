From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] net: Kill sock->sk_protinfo
Date: Thu, 25 Jun 2015 06:19:15 -0700 (PDT)
Message-ID: <20150625.061915.375007657782667105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, edumazet@google.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47545 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbFYNHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:07:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No more users, so it can now be removed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sock.h |    2 --
 net/core/sock.c    |    1 -
 net/sctp/socket.c  |    6 ------
 3 files changed, 9 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 14d539c..05a8c1a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -277,7 +277,6 @@ struct cg_proto;
   *	@sk_incoming_cpu: record cpu processing incoming packets
   *	@sk_txhash: computed flow hash for use on transmit
   *	@sk_filter: socket filtering instructions
-  *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
   *	@sk_stamp: time stamp of last packet received
   *	@sk_tsflags: SO_TIMESTAMPING socket options
@@ -416,7 +415,6 @@ struct sock {
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	long			sk_sndtimeo;
-	void			*sk_protinfo;
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;
 	u16			sk_tsflags;
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e1fe9a..e4be66f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2269,7 +2269,6 @@ static void sock_def_write_space(struct sock *sk)
 
 static void sock_def_destruct(struct sock *sk)
 {
-	kfree(sk->sk_protinfo);
 }
 
 void sk_send_sigurg(struct sock *sk)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5f6c4e6..1425ec2 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2121,12 +2121,6 @@ static int sctp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 	if (sp->subscribe.sctp_data_io_event)
 		sctp_ulpevent_read_sndrcvinfo(event, msg);
 
-#if 0
-	/* FIXME: we should be calling IP/IPv6 layers.  */
-	if (sk->sk_protinfo.af_inet.cmsg_flags)
-		ip_cmsg_recv(msg, skb);
-#endif
-
 	err = copied;
 
 	/* If skb's length exceeds the user's buffer, update the skb and
-- 
1.7.10.4
