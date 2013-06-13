From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/4] net: sctp: minor: remove variable in sctp_init_sock
Date: Thu, 13 Jun 2013 18:04:22 +0200
Message-ID: <1371139463-12512-4-git-send-email-dborkman@redhat.com>
References: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755049Ab3FMQEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 12:04:31 -0400
In-Reply-To: <1371139463-12512-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's only used at this one time, so we could remove it as well.
This is valid and also makes it more explicit/obvious that in case
of error the sp->ep is NULL here, i.e. for the sctp_destroy_sock()
check that was recently added.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f631c5f..510dc79 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3862,7 +3862,6 @@ out:
 SCTP_STATIC int sctp_init_sock(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
-	struct sctp_endpoint *ep;
 	struct sctp_sock *sp;
 
 	SCTP_DEBUG_PRINTK("sctp_init_sock(sk: %p)\n", sk);
@@ -3971,11 +3970,10 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	 * change the data structure relationships, this may still
 	 * be useful for storing pre-connect address information.
 	 */
-	ep = sctp_endpoint_new(sk, GFP_KERNEL);
-	if (!ep)
+	sp->ep = sctp_endpoint_new(sk, GFP_KERNEL);
+	if (!sp->ep)
 		return -ENOMEM;
 
-	sp->ep = ep;
 	sp->hmac = NULL;
 
 	SCTP_DBG_OBJCNT_INC(sock);
-- 
1.7.11.7
