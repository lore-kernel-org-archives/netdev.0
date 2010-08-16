From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 13/16] net/ax25: Use available error codes
Date: Mon, 16 Aug 2010 18:28:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008161828030.19313__41958.8357945488$1281976214$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Joerg Reuter <jreuter@yaina.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	"D, avid S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:50889 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab0HPQ2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 12:28:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Error codes are stored in err, but the return value is always 0.  Return
err instead.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r@
local idexpression x;
constant C;
@@

if (...) { ...
  x = -C
  ... when != x
(
  return <+...x...+>;
|
  return NULL;
|
  return;
|
* return ...;
)
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This changes the semantics of the function and has not been tested.

 net/ax25/af_ax25.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index cfdfd7e..26eaebf 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1103,7 +1103,7 @@ done:
 out:
 	release_sock(sk);
 
-	return 0;
+	return err;
 }
 
 /*
