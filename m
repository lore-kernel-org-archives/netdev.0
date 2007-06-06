From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] tcp_probe: __attribute__ string location
Date: Tue, 5 Jun 2007 18:01:41 -0700
Message-ID: <20070605180141.e4692374.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33579 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152AbXFFBBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 21:01:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

gcc doesn't like the location of the __attribute__ string here:
net/ipv4/tcp_probe.c:83: warning: empty declaration

so move it to before the function and all is well.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/ipv4/tcp_probe.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2622-rc4.orig/net/ipv4/tcp_probe.c
+++ linux-2622-rc4/net/ipv4/tcp_probe.c
@@ -62,6 +62,7 @@ struct {
  * Print to log with timestamps.
  * FIXME: causes an extra copy
  */
+__attribute__ ((format (printf, 1, 2)))
 static void printl(const char *fmt, ...)
 {
 	va_list args;
@@ -80,7 +81,7 @@ static void printl(const char *fmt, ...)
 
 	kfifo_put(tcpw.fifo, tbuf, len);
 	wake_up(&tcpw.wait);
-} __attribute__ ((format (printf, 1, 2)));
+};
 
 
 /*
