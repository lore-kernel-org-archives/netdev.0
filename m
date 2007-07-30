From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] [NET]: fix multicast list when cloning sockets
Date: Mon, 30 Jul 2007 13:04:48 -0300
Message-ID: <20070730160448.GA4002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35037 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761345AbXG3QMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 12:12:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The sock_copy() function uses memcpy() to clone the socket
including the struct ip_mc_socklist *mc_list pointer.

The ip_mc_drop_socket() function is called when socket is closed
to free these objects leaving the other sockets cloned from the
same master socket with invalid pointers.

This patch sets mc_list of cloned socket to NULL.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index fbe7714..8ee0f54 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -506,6 +506,8 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 		newicsk->icsk_backoff	  = 0;
 		newicsk->icsk_probes_out  = 0;
 
+		inet_sk(inet)->mc_list = NULL;
+
 		/* Deinitialize accept_queue to trap illegal accesses. */
 		memset(&newicsk->icsk_accept_queue, 0, sizeof(newicsk->icsk_accept_queue));
 
-- 
1.5.2.4

-- 
Flavio
