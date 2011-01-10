From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH] caif: don't set connection request param size before
 copying data
Date: Mon, 10 Jan 2011 18:36:37 -0500
Message-ID: <1294702597.2125.74.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:54290 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554Ab1AJXgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 18:36:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The size field should not be set until after the data is successfully
copied in.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
---
 net/caif/caif_socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 1bf0cf5..8184c03 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -740,12 +740,12 @@ static int setsockopt(struct socket *sock,
 		if (cf_sk->sk.sk_protocol != CAIFPROTO_UTIL)
 			return -ENOPROTOOPT;
 		lock_sock(&(cf_sk->sk));
-		cf_sk->conn_req.param.size = ol;
 		if (ol > sizeof(cf_sk->conn_req.param.data) ||
 			copy_from_user(&cf_sk->conn_req.param.data, ov, ol)) {
 			release_sock(&cf_sk->sk);
 			return -EINVAL;
 		}
+		cf_sk->conn_req.param.size = ol;
 		release_sock(&cf_sk->sk);
 		return 0;
 


