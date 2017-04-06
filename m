From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] crypto: af_alg - Allow arbitrarily long algorithm names
Date: Thu, 06 Apr 2017 16:16:09 +0800
Message-ID: <E1cw2aP-00085S-Q4@gondobar>
References: <20170406081509.GB30557@gondor.apana.org.au>
To: Alexander Sverdlin <alexander.sverdlin@nokia.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the hard-coded 64-byte limit on the length
of the algorithm name through bind(2).  The address length can
now exceed that.  The user-space structure remains unchanged.
In order to use a longer name simply extend the salg_name array
beyond its defined 64 bytes length.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/af_alg.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 690deca..3556d8e 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -160,11 +160,11 @@ static int alg_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (sock->state == SS_CONNECTED)
 		return -EINVAL;
 
-	if (addr_len != sizeof(*sa))
+	if (addr_len < sizeof(*sa))
 		return -EINVAL;
 
 	sa->salg_type[sizeof(sa->salg_type) - 1] = 0;
-	sa->salg_name[sizeof(sa->salg_name) - 1] = 0;
+	sa->salg_name[sizeof(sa->salg_name) + addr_len - sizeof(*sa) - 1] = 0;
 
 	type = alg_get_type(sa->salg_type);
 	if (IS_ERR(type) && PTR_ERR(type) == -ENOENT) {
