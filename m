From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 2/2] SCTP: fix sparse warning
Date: Thu, 18 Feb 2010 21:55:22 -0800
Message-ID: <20100219055628.517807379@vyatta.com>
References: <20100219055520.223027612@vyatta.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34719 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492Ab0BSF7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 00:59:14 -0500
Content-Disposition: inline; filename=sctp-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The variable node shadows earlier one in same function.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sctp/socket.c	2010-02-18 10:06:57.656887238 -0800
+++ b/net/sctp/socket.c	2010-02-18 10:07:09.894132363 -0800
@@ -5478,7 +5478,7 @@ pp_found:
 		 */
 		int reuse = sk->sk_reuse;
 		struct sock *sk2;
-		struct hlist_node *node;
+		struct hlist_node *node2;
 
 		SCTP_DEBUG_PRINTK("sctp_get_port() found a possible match\n");
 		if (pp->fastreuse && sk->sk_reuse &&
@@ -5495,7 +5495,7 @@ pp_found:
 		 * that this port/socket (sk) combination are already
 		 * in an endpoint.
 		 */
-		sk_for_each_bound(sk2, node, &pp->owner) {
+		sk_for_each_bound(sk2, node2, &pp->owner) {
 			struct sctp_endpoint *ep2;
 			ep2 = sctp_sk(sk2)->ep;
 

-- 

