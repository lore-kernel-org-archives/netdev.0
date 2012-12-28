From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [RFC PATCH 1/3] xfrm_algo: probe asynchronous block ciphers instead
 of synchronous
Date: Fri, 28 Dec 2012 12:04:53 +0200
Message-ID: <20121228100453.11073.55014.stgit@localhost6.localdomain6>
References: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20121228100448.11073.25546.stgit@localhost6.localdomain6>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPSEC uses block ciphers asynchronous, but probes only for synchronous block
ciphers and makes ealg entries only available if synchronous block cipher is
found. So with setup, where hardware crypto driver registers asynchronous
block ciphers and software crypto module is not build, ealg is not marked
as being available.

Use crypto_has_ablkcipher instead and remove ASYNC mask.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---
 net/xfrm/xfrm_algo.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 4ce2d93..f9a5495 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -700,8 +700,7 @@ void xfrm_probe_algs(void)
 	}
 
 	for (i = 0; i < ealg_entries(); i++) {
-		status = crypto_has_blkcipher(ealg_list[i].name, 0,
-					      CRYPTO_ALG_ASYNC);
+		status = crypto_has_ablkcipher(ealg_list[i].name, 0, 0);
 		if (ealg_list[i].available != status)
 			ealg_list[i].available = status;
 	}
