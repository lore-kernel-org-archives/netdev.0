From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC] [PATCH 01/11] crypto: scatterwalk - Add
 scatterwalk_crypto_chain helper
Date: Mon, 22 Nov 2010 11:25:50 +0100
Message-ID: <20101122102550.GD1868@secunet.com>
References: <20101122102455.GC1868@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Alex Badea <abadea@ixiacom.com>, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101122102455.GC1868@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A lot of crypto algorithms implement their own chaining function.
So add a generic one that can be used from all the algorithms that
need scatterlist chaining.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/crypto/scatterwalk.h |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/crypto/scatterwalk.h b/include/crypto/scatterwalk.h
index 833d208..4fd95a3 100644
--- a/include/crypto/scatterwalk.h
+++ b/include/crypto/scatterwalk.h
@@ -68,6 +68,21 @@ static inline struct scatterlist *scatterwalk_sg_next(struct scatterlist *sg)
 	return (++sg)->length ? sg : (void *)sg_page(sg);
 }
 
+static inline void scatterwalk_crypto_chain(struct scatterlist *head,
+					    struct scatterlist *sg,
+					    int chain, int num)
+{
+	if (chain) {
+		head->length += sg->length;
+		sg = scatterwalk_sg_next(sg);
+	}
+
+	if (sg)
+		scatterwalk_sg_chain(head, num, sg);
+	else
+		sg_mark_end(head);
+}
+
 static inline unsigned long scatterwalk_samebuf(struct scatter_walk *walk_in,
 						struct scatter_walk *walk_out)
 {
-- 
1.7.0.4
