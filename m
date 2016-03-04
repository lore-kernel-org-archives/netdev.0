From: David Howells <dhowells@redhat.com>
Subject: [PATCH 11/13] rxrpc: rxkad: Casts are needed when comparing be32
 values
Date: Fri, 04 Mar 2016 16:38:21 +0000
Message-ID: <20160304163821.31057.12253.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forced casts are needed to avoid sparse warning when directly comparing
be32 values.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/rxkad.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ca746f382517..3106a0c4960b 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -142,7 +142,7 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
-	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf.x[2]);
+	ASSERTCMP((u32 __force)conn->csum_iv.n[0], ==, (u32 __force)tmpbuf.x[2]);
 
 	_leave("");
 }
