From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 2/2] net: netfilter: Remove typedef from "typedef struct bitstr_t"
Date: Sat, 25 Mar 2017 17:57:56 +0530
Message-ID: <20170325122756.8743-3-arushisinghal19971997@gmail.com>
References: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
Cc: pablo@netfilter.org, davem@davemloft.net,
        outreachy-kernel@googlegroups.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, gregkh@linuxfoundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: kadlec@blackhole.kfki.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170325122756.8743-1-arushisinghal19971997@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes typedefs from struct and renames it from "typedef struct
bitstr_t" to "struct bitstr" as per kernel coding standards."

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/nf_conntrack_h323_asn1.c | 80 +++++++++++++++++-----------------
 1 file changed, 40 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index fb8cf238a76f..4502c0d6071d 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -91,41 +91,41 @@ struct field {
 };
 
 /* Bit Stream */
-typedef struct {
+struct bitstr {
 	unsigned char *buf;
 	unsigned char *beg;
 	unsigned char *end;
 	unsigned char *cur;
 	unsigned int bit;
-} bitstr_t;
+};
 
 /* Tool Functions */
 #define INC_BIT(bs) if((++(bs)->bit)>7){(bs)->cur++;(bs)->bit=0;}
 #define INC_BITS(bs,b) if(((bs)->bit+=(b))>7){(bs)->cur+=(bs)->bit>>3;(bs)->bit&=7;}
 #define BYTE_ALIGN(bs) if((bs)->bit){(bs)->cur++;(bs)->bit=0;}
 #define CHECK_BOUND(bs,n) if((bs)->cur+(n)>(bs)->end)return(H323_ERROR_BOUND)
-static unsigned int get_len(bitstr_t *bs);
-static unsigned int get_bit(bitstr_t *bs);
-static unsigned int get_bits(bitstr_t *bs, unsigned int b);
-static unsigned int get_bitmap(bitstr_t *bs, unsigned int b);
-static unsigned int get_uint(bitstr_t *bs, int b);
+static unsigned int get_len(struct bitstr *bs);
+static unsigned int get_bit(struct bitstr *bs);
+static unsigned int get_bits(struct bitstr *bs, unsigned int b);
+static unsigned int get_bitmap(struct bitstr *bs, unsigned int b);
+static unsigned int get_uint(struct bitstr *bs, int b);
 
 /* Decoder Functions */
-static int decode_nul(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_bool(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_oid(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_int(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_enum(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_bitstr(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_numstr(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_octstr(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_bmpstr(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_seq(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_seqof(bitstr_t *bs, const struct field *f, char *base, int level);
-static int decode_choice(bitstr_t *bs, const struct field *f, char *base, int level);
+static int decode_nul(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_bool(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_oid(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_int(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_enum(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_bitstr(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_numstr(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_octstr(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_bmpstr(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_seq(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_seqof(struct bitstr *bs, const struct field *f, char *base, int level);
+static int decode_choice(struct bitstr *bs, const struct field *f, char *base, int level);
 
 /* Decoder Functions Vector */
-typedef int (*decoder_t)(bitstr_t *, const struct field *, char *, int);
+typedef int (*decoder_t)(struct bitstr *, const struct field *, char *, int);
 static const decoder_t Decoders[] = {
 	decode_nul,
 	decode_bool,
@@ -150,7 +150,7 @@ static const decoder_t Decoders[] = {
  * Functions
  ****************************************************************************/
 /* Assume bs is aligned && v < 16384 */
-static unsigned int get_len(bitstr_t *bs)
+static unsigned int get_len(struct bitstr *bs)
 {
 	unsigned int v;
 
@@ -166,7 +166,7 @@ static unsigned int get_len(bitstr_t *bs)
 }
 
 /****************************************************************************/
-static unsigned int get_bit(bitstr_t *bs)
+static unsigned int get_bit(struct bitstr *bs)
 {
 	unsigned int b = (*bs->cur) & (0x80 >> bs->bit);
 
@@ -177,7 +177,7 @@ static unsigned int get_bit(bitstr_t *bs)
 
 /****************************************************************************/
 /* Assume b <= 8 */
-static unsigned int get_bits(bitstr_t *bs, unsigned int b)
+static unsigned int get_bits(struct bitstr *bs, unsigned int b)
 {
 	unsigned int v, l;
 
@@ -203,7 +203,7 @@ static unsigned int get_bits(bitstr_t *bs, unsigned int b)
 
 /****************************************************************************/
 /* Assume b <= 32 */
-static unsigned int get_bitmap(bitstr_t *bs, unsigned int b)
+static unsigned int get_bitmap(struct bitstr *bs, unsigned int b)
 {
 	unsigned int v, l, shift, bytes;
 
@@ -242,7 +242,7 @@ static unsigned int get_bitmap(bitstr_t *bs, unsigned int b)
 /****************************************************************************
  * Assume bs is aligned and sizeof(unsigned int) == 4
  ****************************************************************************/
-static unsigned int get_uint(bitstr_t *bs, int b)
+static unsigned int get_uint(struct bitstr *bs, int b)
 {
 	unsigned int v = 0;
 
@@ -264,7 +264,7 @@ static unsigned int get_uint(bitstr_t *bs, int b)
 }
 
 /****************************************************************************/
-static int decode_nul(bitstr_t *bs, const struct field *f,
+static int decode_nul(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -273,7 +273,7 @@ static int decode_nul(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_bool(bitstr_t *bs, const struct field *f,
+static int decode_bool(struct bitstr *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -285,7 +285,7 @@ static int decode_bool(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_oid(bitstr_t *bs, const struct field *f,
+static int decode_oid(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	int len;
@@ -302,7 +302,7 @@ static int decode_oid(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_int(bitstr_t *bs, const struct field *f,
+static int decode_int(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int len;
@@ -346,7 +346,7 @@ static int decode_int(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_enum(bitstr_t *bs, const struct field *f,
+static int decode_enum(struct bitstr *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -362,7 +362,7 @@ static int decode_enum(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_bitstr(bitstr_t *bs, const struct field *f,
+static int decode_bitstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -396,7 +396,7 @@ static int decode_bitstr(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_numstr(bitstr_t *bs, const struct field *f,
+static int decode_numstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -414,7 +414,7 @@ static int decode_numstr(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_octstr(bitstr_t *bs, const struct field *f,
+static int decode_octstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -463,7 +463,7 @@ static int decode_octstr(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_bmpstr(bitstr_t *bs, const struct field *f,
+static int decode_bmpstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -489,7 +489,7 @@ static int decode_bmpstr(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_seq(bitstr_t *bs, const struct field *f,
+static int decode_seq(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int ext, bmp, i, opt, len = 0, bmp2, bmp2_len;
@@ -606,7 +606,7 @@ static int decode_seq(bitstr_t *bs, const struct field *f,
 }
 
 /****************************************************************************/
-static int decode_seqof(bitstr_t *bs, const struct field *f,
+static int decode_seqof(struct bitstr *bs, const struct field *f,
                         char *base, int level)
 {
 	unsigned int count, effective_count = 0, i, len = 0;
@@ -696,7 +696,7 @@ static int decode_seqof(bitstr_t *bs, const struct field *f,
 
 
 /****************************************************************************/
-static int decode_choice(bitstr_t *bs, const struct field *f,
+static int decode_choice(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int type, ext, len = 0;
@@ -772,7 +772,7 @@ int DecodeRasMessage(unsigned char *buf, size_t sz, RasMessage *ras)
 		FNAME("RasMessage") CHOICE, 5, 24, 32, DECODE | EXT,
 		0, _RasMessage
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = bs.beg = bs.cur = buf;
 	bs.end = buf + sz;
@@ -789,7 +789,7 @@ static int DecodeH323_UserInformation(unsigned char *buf, unsigned char *beg,
 		FNAME("H323-UserInformation") SEQ, 1, 2, 2, DECODE | EXT,
 		0, _H323_UserInformation
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = buf;
 	bs.beg = bs.cur = beg;
@@ -808,7 +808,7 @@ int DecodeMultimediaSystemControlMessage(unsigned char *buf, size_t sz,
 		FNAME("MultimediaSystemControlMessage") CHOICE, 2, 4, 4,
 		DECODE | EXT, 0, _MultimediaSystemControlMessage
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = bs.beg = bs.cur = buf;
 	bs.end = buf + sz;
-- 
2.11.0
