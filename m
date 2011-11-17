From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] RxRPC: Use kmemdup rather than duplicating its
 implementation
Date: Thu, 17 Nov 2011 23:43:40 +0100
Message-ID: <1321569820.1624.308.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The semantic patch that makes this change is available
in scripts/coccinelle/api/memdup.cocci.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
--- a/net/rxrpc/ar-key.c 2011-11-07 19:38:32.050621708 +0100
+++ b/net/rxrpc/ar-key.c 2011-11-08 10:59:18.926240106 +0100
@@ -306,10 +306,9 @@ static int rxrpc_krb5_decode_tagged_data
 	td->data_len = len;
 
 	if (len > 0) {
-		td->data = kmalloc(len, GFP_KERNEL);
+		td->data = kmemdup(xdr, len, GFP_KERNEL);
 		if (!td->data)
 			return -ENOMEM;
-		memcpy(td->data, xdr, len);
 		len = (len + 3) & ~3;
 		toklen -= len;
 		xdr += len >> 2;
@@ -401,10 +400,9 @@ static int rxrpc_krb5_decode_ticket(u8 *
 	_debug("ticket len %u", len);
 
 	if (len > 0) {
-		*_ticket = kmalloc(len, GFP_KERNEL);
+		*_ticket = kmemdup(xdr, len, GFP_KERNEL);
 		if (!*_ticket)
 			return -ENOMEM;
-		memcpy(*_ticket, xdr, len);
 		len = (len + 3) & ~3;
 		toklen -= len;
 		xdr += len >> 2;
