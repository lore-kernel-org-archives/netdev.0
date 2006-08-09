From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] sock_create bad error return
Date: Wed, 09 Aug 2006 11:31:39 -0700
Message-ID: <20060809183348.999358659@localhost.localdomain>
References: <20060809183138.332023530@localhost.localdomain>
Cc: Paul McKenney <paulmck@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10688 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751309AbWHISlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 14:41:12 -0400
To: David Miller <davem@davemloft.net>
Cc: akpm@osdl.org
Content-Disposition: inline; filename=socket-get-race.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If socket create call races with module unload, it correctly
fails the socket call but doesn't return an error. This race
is theoritical because the sock->ops are always the same and
non-modular.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- tcp-2.6.orig/net/socket.c
+++ tcp-2.6/net/socket.c
@@ -1204,6 +1204,7 @@ static int __sock_create(int family, int
 	 * socket at sock_release time we decrement its refcnt.
 	 */
 	if (!try_module_get(sock->ops->owner)) {
+		err = -EAGAIN;
 		sock->ops = NULL;
 		goto out_module_put;
 	}

--

