From: Julien Brunel <brunel@diku.dk>
Subject: [PATCH] net/rxrpc: Use an IS_ERR test rather than a NULL test
Date: Fri, 8 Aug 2008 13:55:21 +0200
Message-ID: <200808081355.21787.brunel@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:36246 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754600AbYHHLz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 07:55:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Brunel <brunel@diku.dk>

In case of error, the function rxrpc_get_transport returns an ERR
pointer, but never returns a NULL pointer. So after a call to this
function, a NULL test should be replaced by an IS_ERR test.

A simplified version of the semantic patch that makes this change is
as follows: 
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@correct_null_test@
expression x,E;
statement S1, S2;
@@
x =  rxrpc_get_transport(...)
<... when != x = E
if (
(
- x@p2 != NULL
+ ! IS_ERR ( x )
|
- x@p2 == NULL
+ IS_ERR( x )
)
 )
S1
else S2
...>
? x = E;
// </smpl>

Signed-off-by:  Julien Brunel <brunel@diku.dk>
Signed-off-by:  Julia Lawall <julia@diku.dk>

---
 net/rxrpc/ar-accept.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -100,7 +100,7 @@ static int rxrpc_accept_incoming_call(st
 
 	trans = rxrpc_get_transport(local, peer, GFP_NOIO);
 	rxrpc_put_peer(peer);
-	if (!trans) {
+	if (IS_ERR(trans)) {
 		_debug("no trans");
 		ret = -EBUSY;
 		goto error;
