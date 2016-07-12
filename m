From: weiyj_lk@163.com
Subject: [PATCH -next] rxrpc: Fix error handling in af_rxrpc_init()
Date: Tue, 12 Jul 2016 11:21:17 +0000
Message-ID: <1468322477-32616-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:49179 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932886AbcGLLV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 07:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

security initialized after alloc workqueue, so we should exit security
before destroy workqueue in the error handing.

Fixes: 648af7fca159 ("rxrpc: Absorb the rxkad security module")
Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/rxrpc/af_rxrpc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index d6e4e3b..88effad 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -766,9 +766,9 @@ error_key_type:
 error_sock:
 	proto_unregister(&rxrpc_proto);
 error_proto:
-	destroy_workqueue(rxrpc_workqueue);
-error_security:
 	rxrpc_exit_security();
+error_security:
+	destroy_workqueue(rxrpc_workqueue);
 error_work_queue:
 	kmem_cache_destroy(rxrpc_call_jar);
 error_call_jar:
