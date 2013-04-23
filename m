From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: mISDN: set ->family in ->getname()
Date: Tue, 23 Apr 2013 09:24:14 +0300
Message-ID: <20130423062414.GC15893@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29723 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754996Ab3DWGYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:24:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "maddr->family" variable was not set but instead it leaked stack
information to userspace.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 8b07f83..a838864 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -578,6 +578,7 @@ data_sock_getname(struct socket *sock, struct sockaddr *addr,
 	lock_sock(sk);
 
 	*addr_len = sizeof(*maddr);
+	maddr->family = AF_ISDN;
 	maddr->dev = _pms(sk)->dev->id;
 	maddr->channel = _pms(sk)->ch.nr;
 	maddr->sapi = _pms(sk)->ch.addr & 0xff;
