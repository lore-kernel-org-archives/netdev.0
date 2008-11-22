From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: af_netlink should update its inuse counter
Date: Sat, 22 Nov 2008 09:40:10 +0100
Message-ID: <4927C56A.5080307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000108040703040205010101"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44037 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYKVIkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 03:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000108040703040205010101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In order to have relevant information for NETLINK protocol, in
/proc/net/protocols, we should use sock_prot_inuse_add() to
update a (percpu and pernamespace) counter of inuse sockets.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------000108040703040205010101
Content-Type: text/plain;
 name="af_netlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_netlink.patch"

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 480184a..a2071dc 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -452,6 +452,7 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol)
 	if (err < 0)
 		goto out_module;
 
+	sock_prot_inuse_add(net, &netlink_proto, 1);
 	nlk = nlk_sk(sock->sk);
 	nlk->module = module;
 out:
@@ -511,6 +512,7 @@ static int netlink_release(struct socket *sock)
 	kfree(nlk->groups);
 	nlk->groups = NULL;
 
+	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	sock_put(sk);
 	return 0;
 }

--------------000108040703040205010101--
