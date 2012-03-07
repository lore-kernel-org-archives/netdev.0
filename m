From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH] xfrm: fix hmac(sha256) truncation length
Date: Wed,  7 Mar 2012 15:12:37 -0500
Message-ID: <1331151157-19149-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Paul Wouters <pwouters@redhat.com>,
	Herber Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Willi <martin@strongswan.org>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit bc74b0c8af17458ecae77f725e507ab5fd100105 added proper hmac sha384
and sha512 variants with truncation lengths of 192 and 256 respectively,
per RFC4868:

http://www.ietf.org/rfc/rfc4868.txt

The already-present hmac sha256 variant was left as-is, with a truncation
length of 96 bits, per an earlier draft of the RFC, as I understand it (it
predates 2.6.12-rc2, didn't look further back). This doesn't play well out
of the box with various other ipsec devices that properly implement the
current RFC value of 128-bit truncation for hmac sha256. Easy fix,
assuming there's not some reason I'm not clued into about why this might
have intentionally been left as-is.

CC: Paul Wouters <pwouters@redhat.com>
CC: Herber Xu <herbert@gondor.apana.org.au>
CC: David S. Miller <davem@davemloft.net>
CC: Martin Willi <martin@strongswan.org>
CC: netdev@vger.kernel.org
CC: linux-crypto@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/xfrm/xfrm_algo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 791ab2e..f2b3ce2 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -203,7 +203,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 
 	.uinfo = {
 		.auth = {
-			.icv_truncbits = 96,
+			.icv_truncbits = 128,
 			.icv_fullbits = 256,
 		}
 	},
-- 
1.7.1
