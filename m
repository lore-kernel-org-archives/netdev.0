From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: af_unix can make unix_nr_socks visbile in /proc
Date: Mon, 17 Nov 2008 08:58:05 +0100
Message-ID: <4921240D.9000409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804030807090403030609"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54583 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbYKQH6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 02:58:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040804030807090403030609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Currently, /proc/net/protocols displays socket counts only for TCP/TCPv6
protocols

We can provide unix_nr_socks for free here, this counter being
already maintained in af_unix

Before patch :

# grep UNIX /proc/net/protocols
UNIX       428     -1      -1   NI       0   yes  kernel

After patch :

# grep UNIX /proc/net/protocols
UNIX       428     98      -1   NI       0   yes  kernel

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/unix/af_unix.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

--------------040804030807090403030609
Content-Type: text/plain;
 name="af_unix_sockets_allocated.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_unix_sockets_allocated.patch"

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 58db2a2..a1eb596 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -566,9 +566,10 @@ static const struct proto_ops unix_seqpacket_ops = {
 };
 
 static struct proto unix_proto = {
-	.name	  = "UNIX",
-	.owner	  = THIS_MODULE,
-	.obj_size = sizeof(struct unix_sock),
+	.name			= "UNIX",
+	.owner			= THIS_MODULE,
+	.sockets_allocated	= &unix_nr_socks,
+	.obj_size		= sizeof(struct unix_sock),
 };
 
 /*

--------------040804030807090403030609--
