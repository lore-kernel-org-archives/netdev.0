From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH] [AF_RXRPC]: constify function pointer tables
Date: Tue, 22 Jan 2008 20:47:51 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801222047350.5722@fbirervta.pbzchgretzou.qr>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33213 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbYAVTrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 14:47:53 -0500
In-Reply-To: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
 net/rxrpc/ar-call.c     |    2 +-
 net/rxrpc/ar-internal.h |    6 +++---
 net/rxrpc/ar-proc.c     |    6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 3c04b00..d923124 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -15,7 +15,7 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-const char *rxrpc_call_states[] = {
+const char *const rxrpc_call_states[] = {
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
 	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 58aaf89..1aaa2e8 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -565,9 +565,9 @@ extern void __exit rxrpc_destroy_all_peers(void);
 /*
  * ar-proc.c
  */
-extern const char *rxrpc_call_states[];
-extern struct file_operations rxrpc_call_seq_fops;
-extern struct file_operations rxrpc_connection_seq_fops;
+extern const char *const rxrpc_call_states[];
+extern const struct file_operations rxrpc_call_seq_fops;
+extern const struct file_operations rxrpc_connection_seq_fops;
 
 /*
  * ar-recvmsg.c
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
index 2e83ce3..83eda24 100644
--- a/net/rxrpc/ar-proc.c
+++ b/net/rxrpc/ar-proc.c
@@ -14,7 +14,7 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
-static const char *rxrpc_conn_states[] = {
+static const char *const rxrpc_conn_states[] = {
 	[RXRPC_CONN_UNUSED]		= "Unused  ",
 	[RXRPC_CONN_CLIENT]		= "Client  ",
 	[RXRPC_CONN_SERVER_UNSECURED]	= "SvUnsec ",
@@ -98,7 +98,7 @@ static int rxrpc_call_seq_open(struct inode *inode, struct file *file)
 	return seq_open(file, &rxrpc_call_seq_ops);
 }
 
-struct file_operations rxrpc_call_seq_fops = {
+const struct file_operations rxrpc_call_seq_fops = {
 	.owner		= THIS_MODULE,
 	.open		= rxrpc_call_seq_open,
 	.read		= seq_read,
@@ -183,7 +183,7 @@ static int rxrpc_connection_seq_open(struct inode *inode, struct file *file)
 	return seq_open(file, &rxrpc_connection_seq_ops);
 }
 
-struct file_operations rxrpc_connection_seq_fops = {
+const struct file_operations rxrpc_connection_seq_fops = {
 	.owner		= THIS_MODULE,
 	.open		= rxrpc_connection_seq_open,
 	.read		= seq_read,
-- 
1.5.3.4

