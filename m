From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()
Date: Mon, 24 Nov 2008 18:23:24 +0100
Message-ID: <492AE30C.70907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000507050300020804040808"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43545 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbYKXRX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 12:23:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000507050300020804040808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Third round of patch about sock_prot_inuse_add() ...

Thanks

[PATCH] net: Make sure BHs are disabled in sock_prot_inuse_add()

There is still a call to sock_prot_inuse_add() in af_netlink
while in a preemptable section. Add explicit BH disable around
this call.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------000507050300020804040808
Content-Type: text/plain;
 name="af_netlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_netlink.patch"

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c7d7657..9eb895c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -515,7 +515,9 @@ static int netlink_release(struct socket *sock)
 	kfree(nlk->groups);
 	nlk->groups = NULL;
 
+	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
+	local_bh_enable();
 	sock_put(sk);
 	return 0;
 }

--------------000507050300020804040808--
