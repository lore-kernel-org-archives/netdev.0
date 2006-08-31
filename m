From: Akinobu Mita <mita@miraclelinux.com>
Subject: [PATCH] rate limiting for socket allocation failure messages
Date: Thu, 31 Aug 2006 18:59:21 +0900
Message-ID: <20060831095921.GA13845@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:25363 "EHLO
	mail01.miraclelinux.com") by vger.kernel.org with ESMTP
	id S1750788AbWHaKER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 06:04:17 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Resending due to local mail server trouble)

This patch limits the warning messages when socket allocation
failures happen. It happens under memory pressure.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

 net/socket.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: work-shouldfail/net/socket.c
===================================================================
--- work-shouldfail.orig/net/socket.c
+++ work-shouldfail/net/socket.c
@@ -1178,7 +1178,8 @@ static int __sock_create(int family, int
  */
 
 	if (!(sock = sock_alloc())) {
-		printk(KERN_WARNING "socket: no more sockets\n");
+		if (net_ratelimit())
+			printk(KERN_WARNING "socket: no more sockets\n");
 		err = -ENFILE;		/* Not exactly a match, but its the
 					   closest posix thing */
 		goto out;
