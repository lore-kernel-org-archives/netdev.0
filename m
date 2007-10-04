From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH] net: fix kernel_accept() error path
Date: Thu, 04 Oct 2007 16:20:05 -0400
Message-ID: <47054AF5.4050409@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host06.cybernetics.com ([206.246.200.22]:1277 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755990AbXJDUlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 16:41:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If accept() returns an error, kernel_accept() releases the new socket
but passes a pointer to the released socket back to the caller.  Make it
pass back NULL instead.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux-2.6.23-rc9/net/socket.c.bak	2007-10-04 15:21:17.000000000 -0400
+++ linux-2.6.23-rc9/net/socket.c	2007-10-04 15:21:22.000000000 -0400
@@ -2230,6 +2230,7 @@ int kernel_accept(struct socket *sock, s
 	err = sock->ops->accept(sock, *newsock, flags);
 	if (err < 0) {
 		sock_release(*newsock);
+		*newsock = NULL;
 		goto done;
 	}
 


