From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 09/14] rxrpc: Validate the net address given to
 rxrpc_kernel_begin_call()
Date: Wed, 22 Jun 2016 10:50:47 +0100
Message-ID: <146658904716.4550.5805807444765528663.stgit@warthog.procyon.org.uk>
References: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Validate the net address given to rxrpc_kernel_begin_call() before using
it.

Whilst this should be mostly unnecessary for in-kernel users, it does clear
the tail of the address struct in case we want to hash or compare the whole
thing.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 408bd024125b..b29bb50af5de 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -280,9 +280,14 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	int ret;
 
 	_enter(",,%x,%lx", key_serial(key), user_call_ID);
 
+	ret = rxrpc_validate_address(rx, srx, sizeof(*srx));
+	if (ret < 0)
+		return ERR_PTR(ret);
+
 	lock_sock(&rx->sk);
 
 	if (!key)
