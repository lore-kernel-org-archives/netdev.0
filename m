From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/7] rxrpc: Update protocol definitions slightly
Date: Thu, 08 Sep 2016 12:43:42 +0100
Message-ID: <147333502280.5646.5563431894532183412.stgit@warthog.procyon.org.uk>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the protocol definitions in include/rxrpc/packet.h slightly:

 (1) Get rid of RXRPC_PROCESS_MAXCALLS as it's redundant (same as
     RXRPC_MAXCALLS).

 (2) In struct rxrpc_jumbo_header, put _rsvd in a union with a field called
     cksum to match struct rxrpc_wire_header.

 (3) Provide RXRPC_JUMBO_SUBPKTLEN which is the total of the amount of data
     in a non-terminal subpacket plus the following secondary header for
     the next packet included in the jumbo packet.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 3c6128e1fdbe..b0ae5c1a6ce6 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -34,8 +34,6 @@ struct rxrpc_wire_header {
 #define RXRPC_CID_INC		(1 << RXRPC_CIDSHIFT)	/* connection ID increment */
 
 	__be32		callNumber;	/* call ID (0 for connection-level packets) */
-#define RXRPC_PROCESS_MAXCALLS	(1<<2)	/* maximum number of active calls per conn (power of 2) */
-
 	__be32		seq;		/* sequence number of pkt in call stream */
 	__be32		serial;		/* serial number of pkt sent to network */
 
@@ -93,10 +91,14 @@ struct rxrpc_wire_header {
 struct rxrpc_jumbo_header {
 	uint8_t		flags;		/* packet flags (as per rxrpc_header) */
 	uint8_t		pad;
-	__be16		_rsvd;		/* reserved (used by kerberos security as cksum) */
+	union {
+		__be16	_rsvd;		/* reserved */
+		__be16	cksum;		/* kerberos security checksum */
+	};
 };
 
 #define RXRPC_JUMBO_DATALEN	1412	/* non-terminal jumbo packet data length */
+#define RXRPC_JUMBO_SUBPKTLEN	(RXRPC_JUMBO_DATALEN + sizeof(struct rxrpc_jumbo_header))
 
 /*****************************************************************************/
 /*
