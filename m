From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [RFC PATCH v2 4/4] ppp_mppe: style cleanup
Date: Tue, 21 May 2013 20:18:24 +0200
Message-ID: <1369160304-31967-4-git-send-email-jorge@dti2.net>
References: <1369160304-31967-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1369160304-31967-1-git-send-email-jorge@dti2.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 drivers/net/ppp/ppp_mppe.c |  104 +++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 54c64cf..4d27245 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -66,8 +66,8 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_ALIAS("ppp-compress-" __stringify(CI_MPPE));
 MODULE_VERSION("1.0.2");
 
-static unsigned int
-setup_sg(struct scatterlist *sg, const void *address, unsigned int length)
+static unsigned int setup_sg(struct scatterlist *sg, const void *address,
+			     unsigned int length)
 {
 	sg_set_buf(sg, address, length);
 	return length;
@@ -138,7 +138,7 @@ struct ppp_mppe_state {
  * Key Derivation, from RFC 3078, RFC 3079.
  * Equivalent to Get_Key() for MS-CHAP as described in RFC 3079.
  */
-static void get_new_key_from_sha(struct ppp_mppe_state * state)
+static void get_new_key_from_sha(struct ppp_mppe_state *state)
 {
 	struct hash_desc desc;
 	struct scatterlist sg[4];
@@ -163,7 +163,7 @@ static void get_new_key_from_sha(struct ppp_mppe_state * state)
  * Perform the MPPE rekey algorithm, from RFC 3078, sec. 7.3.
  * Well, not what's written there, but rather what they meant.
  */
-static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
+static void mppe_rekey(struct ppp_mppe_state *state, int initial_key)
 {
 	struct scatterlist sg_in[1], sg_out[1];
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
@@ -209,7 +209,6 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	if (state == NULL)
 		goto out;
 
-
 	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(state->arc4)) {
 		state->arc4 = NULL;
@@ -243,15 +242,15 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 
 	return (void *)state;
 
-	out_free:
-	    if (state->sha1_digest)
+out_free:
+	if (state->sha1_digest)
 		kfree(state->sha1_digest);
-	    if (state->sha1)
+	if (state->sha1)
 		crypto_free_hash(state->sha1);
-	    if (state->arc4)
+	if (state->arc4)
 		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
-	out:
+	kfree(state);
+out:
 	return NULL;
 }
 
@@ -260,26 +259,25 @@ static void *mppe_alloc(unsigned char *options, int optlen)
  */
 static void mppe_free(void *arg)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	if (state) {
-	    if (state->sha1_digest)
-		kfree(state->sha1_digest);
-	    if (state->sha1)
-		crypto_free_hash(state->sha1);
-	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
-	    kfree(state);
+		if (state->sha1_digest)
+			kfree(state->sha1_digest);
+		if (state->sha1)
+			crypto_free_hash(state->sha1);
+		if (state->arc4)
+			crypto_free_blkcipher(state->arc4);
+		kfree(state);
 	}
 }
 
 /*
  * Initialize (de)compressor state.
  */
-static int
-mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
-	  const char *debugstr)
+static int mppe_init(void *arg, unsigned char *options, int optlen, int unit,
+		     int debug, const char *debugstr)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	unsigned char mppe_opts;
 
 	if (optlen != CILEN_MPPE ||
@@ -338,9 +336,8 @@ mppe_init(void *arg, unsigned char *options, int optlen, int unit, int debug,
 	return 1;
 }
 
-static int
-mppe_comp_init(void *arg, unsigned char *options, int optlen, int unit,
-	       int hdrlen, int debug)
+static int mppe_comp_init(void *arg, unsigned char *options, int optlen,
+			  int unit, int hdrlen, int debug)
 {
 	/* ARGSUSED */
 	return mppe_init(arg, options, optlen, unit, debug, "mppe_comp_init");
@@ -357,7 +354,7 @@ mppe_comp_init(void *arg, unsigned char *options, int optlen, int unit,
  */
 static void mppe_comp_reset(void *arg)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	state->bits |= MPPE_BIT_FLUSHED;
 }
@@ -367,11 +364,10 @@ static void mppe_comp_reset(void *arg)
  * It's strange to call this a compressor, since the output is always
  * MPPE_OVHD + 2 bytes larger than the input.
  */
-static int
-mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
-	      int isize, int osize)
+static int mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
+			 int isize, int osize)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	int proto;
 	struct scatterlist sg_in[1], sg_out[1];
@@ -450,14 +446,13 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
  */
 static void mppe_comp_stats(void *arg, struct compstat *stats)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	*stats = state->stats;
 }
 
-static int
-mppe_decomp_init(void *arg, unsigned char *options, int optlen, int unit,
-		 int hdrlen, int mru, int debug)
+static int mppe_decomp_init(void *arg, unsigned char *options, int optlen,
+			    int unit, int hdrlen, int mru, int debug)
 {
 	/* ARGSUSED */
 	return mppe_init(arg, options, optlen, unit, debug, "mppe_decomp_init");
@@ -483,11 +478,10 @@ static int mppe_cmp_ccount(unsigned int a, unsigned int b)
 /*
  * Decompress (decrypt) an MPPE packet.
  */
-static int
-mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
-		int osize)
+static int mppe_decompress(void *arg, unsigned char *ibuf, int isize,
+			   unsigned char *obuf, int osize)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	unsigned ccount;
 	int flushed = MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
@@ -685,7 +679,7 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
  */
 static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
 {
-	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct ppp_mppe_state *state = (struct ppp_mppe_state *)arg;
 
 	if (state->debug &&
 	    (PPP_PROTOCOL(ibuf) >= 0x0021 && PPP_PROTOCOL(ibuf) <= 0x00fa))
@@ -708,21 +702,21 @@ static void mppe_incomp(void *arg, unsigned char *ibuf, int icnt)
  */
 static struct compressor ppp_mppe = {
 	.compress_proto = CI_MPPE,
-	.comp_alloc     = mppe_alloc,
-	.comp_free      = mppe_free,
-	.comp_init      = mppe_comp_init,
-	.comp_reset     = mppe_comp_reset,
-	.compress       = mppe_compress,
-	.comp_stat      = mppe_comp_stats,
-	.decomp_alloc   = mppe_alloc,
-	.decomp_free    = mppe_free,
-	.decomp_init    = mppe_decomp_init,
-	.decomp_reset   = mppe_decomp_reset,
-	.decompress     = mppe_decompress,
-	.incomp         = mppe_incomp,
-	.decomp_stat    = mppe_comp_stats,
-	.owner          = THIS_MODULE,
-	.comp_extra     = MPPE_PAD,
+	.comp_alloc = mppe_alloc,
+	.comp_free = mppe_free,
+	.comp_init = mppe_comp_init,
+	.comp_reset = mppe_comp_reset,
+	.compress = mppe_compress,
+	.comp_stat = mppe_comp_stats,
+	.decomp_alloc = mppe_alloc,
+	.decomp_free = mppe_free,
+	.decomp_init = mppe_decomp_init,
+	.decomp_reset = mppe_decomp_reset,
+	.decompress = mppe_decompress,
+	.incomp = mppe_incomp,
+	.decomp_stat = mppe_comp_stats,
+	.owner = THIS_MODULE,
+	.comp_extra = MPPE_PAD,
 };
 
 /*
-- 
1.7.10.4


