From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_RXRPC: Return the number of bytes buffered in
	rxrpc_send_data()
Date: Mon, 18 Jun 2007 12:52:36 +0100
Message-ID: <20070618115236.23639.71608.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dhowells@redhat.com
To: bunk@stusta.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762697AbXFRLyV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return the number of bytes buffered in rxrpc_send_data().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-output.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 591c442..cc9102c 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -640,6 +640,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			goto efault;
 		sp->remain -= copy;
 		skb->mark += copy;
+		copied += copy;
 
 		len -= copy;
 		segment -= copy;
@@ -709,6 +710,8 @@ static int rxrpc_send_data(struct kiocb *iocb,
 
 	} while (segment > 0);
 
+success:
+	ret = copied;
 out:
 	call->tx_pending = skb;
 	_leave(" = %d", ret);
@@ -725,7 +728,7 @@ call_aborted:
 
 maybe_error:
 	if (copied)
-		ret = copied;
+		goto success;
 	goto out;
 
 efault:
