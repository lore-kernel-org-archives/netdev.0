From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v2 net-next] ipv4: Fix compilation errors in fib_rebalance
Date: Tue,  6 Oct 2015 07:24:47 +0200
Message-ID: <1444109087-30676-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Peter Noerlund" <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:46387 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbbJFFY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 01:24:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes

net/built-in.o: In function `fib_rebalance':
fib_semantics.c:(.text+0x9df14): undefined reference to `__divdi3'

and

net/built-in.o: In function `fib_rebalance':
net/ipv4/fib_semantics.c:572: undefined reference to `__aeabi_ldivmod'

=46ixes: 0e884c78ee19 ("ipv4: L3 hash-based multipath")

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 net/ipv4/fib_semantics.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 0c49d2f..7bd698c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -569,8 +569,8 @@ static void fib_rebalance(struct fib_info *fi)
 			upper_bound =3D -1;
 		} else {
 			w +=3D nexthop_nh->nh_weight;
-			upper_bound =3D DIV_ROUND_CLOSEST(2147483648LL * w,
-							total) - 1;
+			upper_bound =3D DIV_ROUND_CLOSEST_ULL((u64)w << 31,
+							    total) - 1;
 		}
=20
 		atomic_set(&nexthop_nh->nh_upper_bound, upper_bound);
--=20
2.1.4
