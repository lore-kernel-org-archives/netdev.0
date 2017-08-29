From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/7] rxrpc: Use correct timestamp from Kerberos 5
 ticket
Date: Tue, 29 Aug 2017 13:27:01 +0100
Message-ID: <150400962111.21371.14070227062428070326.stgit@warthog.procyon.org.uk>
References: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150400960745.21371.15455867950162722742.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When an XDR-encoded Kerberos 5 ticket is added as an rxrpc-type key, the
expiry time should be drawn from the k5 part of the token union (which was
what was filled in), rather than the kad part of the union.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index e2d36619b53a..e7f6b8823eb6 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -536,7 +536,7 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
 	     pptoken = &(*pptoken)->next)
 		continue;
 	*pptoken = token;
-	expiry = rxrpc_u32_to_time64(token->kad->expiry);
+	expiry = rxrpc_u32_to_time64(token->k5->endtime);
 	if (expiry < prep->expiry)
 		prep->expiry = expiry;
 
