From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] net: x25: mark expected switch fall-throughs
Date: Fri, 20 Oct 2017 12:37:52 -0500
Message-ID: <20171020173752.GA10123@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Andrew Hendry <andrew.hendry@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only (GCC 7.2.0 was used).
Please, verify if the actual intention of the code is to fall through.

 net/x25/x25_facilities.c | 2 +-
 net/x25/x25_in.c         | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 997ff7b..ad1734d 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -103,7 +103,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 					*vc_fac_mask |= X25_MASK_REVERSE;
 					break;
 				}
-
+				/*fall through */
 			case X25_FAC_THROUGHPUT:
 				facilities->throughput = p[1];
 				*vc_fac_mask |= X25_MASK_THROUGHPUT;
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index 7ac5009..3c12cae 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -345,6 +345,7 @@ static int x25_state4_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 
 		case X25_RESET_REQUEST:
 			x25_write_internal(sk, X25_RESET_CONFIRMATION);
+			/* fall through */
 		case X25_RESET_CONFIRMATION: {
 			x25_stop_timer(sk);
 			x25->condition = 0x00;
-- 
2.7.4
