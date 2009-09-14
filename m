From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/4] RxRPC: Declare the security index constants symbolically
Date: Mon, 14 Sep 2009 12:17:30 +0100
Message-ID: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbZINLRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 07:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declare the security index constants symbolically rather than just referring
to them numerically.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/rxrpc.h |    7 +++++++
 net/rxrpc/ar-key.c    |    4 ++--
 net/rxrpc/rxkad.c     |    6 +++---
 3 files changed, 12 insertions(+), 5 deletions(-)


diff --git a/include/linux/rxrpc.h b/include/linux/rxrpc.h
index f7b826b..a53915c 100644
--- a/include/linux/rxrpc.h
+++ b/include/linux/rxrpc.h
@@ -58,5 +58,12 @@ struct sockaddr_rxrpc {
 #define RXRPC_SECURITY_AUTH	1	/* authenticated packets */
 #define RXRPC_SECURITY_ENCRYPT	2	/* encrypted packets */
 
+/*
+ * RxRPC security indices
+ */
+#define RXRPC_SECURITY_NONE	0	/* no security protocol */
+#define RXRPC_SECURITY_RXKAD	2	/* kaserver or kerberos 4 */
+#define RXRPC_SECURITY_RXGK	4	/* gssapi-based */
+#define RXRPC_SECURITY_RXK5	5	/* kerberos 5 */
 
 #endif /* _LINUX_RXRPC_H */
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index ad8c7a7..b3d10e7 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -122,7 +122,7 @@ static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 		       tsec->ticket[6], tsec->ticket[7]);
 
 	ret = -EPROTONOSUPPORT;
-	if (tsec->security_index != 2)
+	if (tsec->security_index != RXRPC_SECURITY_RXKAD)
 		goto error;
 
 	key->type_data.x[0] = tsec->security_index;
@@ -308,7 +308,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 	_debug("key %d", key_serial(key));
 
 	data.kver = 1;
-	data.tsec.security_index = 2;
+	data.tsec.security_index = RXRPC_SECURITY_RXKAD;
 	data.tsec.ticket_len = 0;
 	data.tsec.expiry = expiry;
 	data.tsec.kvno = 0;
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ef8f910..acec762 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -42,7 +42,7 @@ struct rxkad_level2_hdr {
 	__be32	checksum;	/* decrypted data checksum */
 };
 
-MODULE_DESCRIPTION("RxRPC network protocol type-2 security (Kerberos)");
+MODULE_DESCRIPTION("RxRPC network protocol type-2 security (Kerberos 4)");
 MODULE_AUTHOR("Red Hat, Inc.");
 MODULE_LICENSE("GPL");
 
@@ -506,7 +506,7 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	if (!call->conn->cipher)
 		return 0;
 
-	if (sp->hdr.securityIndex != 2) {
+	if (sp->hdr.securityIndex != RXRPC_SECURITY_RXKAD) {
 		*_abort_code = RXKADINCONSISTENCY;
 		_leave(" = -EPROTO [not rxkad]");
 		return -EPROTO;
@@ -1122,7 +1122,7 @@ static void rxkad_clear(struct rxrpc_connection *conn)
 static struct rxrpc_security rxkad = {
 	.owner				= THIS_MODULE,
 	.name				= "rxkad",
-	.security_index			= RXKAD_VERSION,
+	.security_index			= RXRPC_SECURITY_RXKAD,
 	.init_connection_security	= rxkad_init_connection_security,
 	.prime_packet_security		= rxkad_prime_packet_security,
 	.secure_packet			= rxkad_secure_packet,

