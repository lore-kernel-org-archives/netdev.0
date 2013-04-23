From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] appletalk: info leak in ->getname()
Date: Tue, 23 Apr 2013 09:22:15 +0300
Message-ID: <20130423062215.GA15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28848 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754570Ab3DWGWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:22:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a one byte hole between ->sat_port and ->sat_addr.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 4a141e3..ef12839 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1253,7 +1253,7 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 			goto out;
 
 	*uaddr_len = sizeof(struct sockaddr_at);
-	memset(&sat.sat_zero, 0, sizeof(sat.sat_zero));
+	memset(&sat, 0, sizeof(sat));
 
 	if (peer) {
 		err = -ENOTCONN;
