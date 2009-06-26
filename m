From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 4/5] ipv6: Use rcu_barrier() on module unload.
Date: Fri, 26 Jun 2009 22:46:03 +0200
Message-ID: <20090626204603.10664.36658.stgit@localhost>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:34400 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbZFZUqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:46:01 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6 module uses rcu_call() thus it should use rcu_barrier() on
module unload.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/ipv6/af_inet6.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 85b3d00..caa0278 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -1284,6 +1284,8 @@ static void __exit inet6_exit(void)
 	proto_unregister(&udplitev6_prot);
 	proto_unregister(&udpv6_prot);
 	proto_unregister(&tcpv6_prot);
+
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 module_exit(inet6_exit);
 

