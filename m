From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] netfilter: h323: Remove typedefs from structs
Date: Tue, 5 Aug 2014 17:35:49 +0530
Message-ID: <20140805120549.GA12723@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch does away with typedefs field_t and bitstr_t as they are
unnecessary.  Also the names of the structs are changed to drop the _t,
to make the names look less typedef-like.

The following Coccinelle semantic patch detects the case.

@tn@
identifier i;
type td;
@@

-typedef
 struct i { ... }
-td
 ;

@@
type tn.td;
identifier tn.i;
@@

-td
+ struct i

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/netfilter/nf_conntrack_h323_asn1.c  | 110 +++++-----
 net/netfilter/nf_conntrack_h323_types.c | 346 ++++++++++++++++----------------
 2 files changed, 234 insertions(+), 222 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index bcd5ed6..deeb368 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -77,7 +77,7 @@
 
 
 /* ASN.1 Field Structure */
-typedef struct field_t {
+struct field {
 #if H323_TRACE
 	char *name;
 #endif
@@ -87,45 +87,57 @@ typedef struct field_t {
 	unsigned char ub;
 	unsigned short attr;
 	unsigned short offset;
-	const struct field_t *fields;
-} field_t;
+	const struct field *fields;
+};
 
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
-static int decode_nul(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bool(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_oid(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_int(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_enum(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bitstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_numstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_octstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_bmpstr(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_seq(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_seqof(bitstr_t *bs, const struct field_t *f, char *base, int level);
-static int decode_choice(bitstr_t *bs, const struct field_t *f, char *base, int level);
+static int decode_nul(struct bitstr *bs, const struct field *f, char *base,
+		      int level);
+static int decode_bool(struct bitstr *bs, const struct field *f, char *base,
+		       int level);
+static int decode_oid(struct bitstr *bs, const struct field *f, char *base,
+		      int level);
+static int decode_int(struct bitstr *bs, const struct field *f, char *base,
+		      int level);
+static int decode_enum(struct bitstr *bs, const struct field *f, char *base,
+		       int level);
+static int decode_bitstr(struct bitstr *bs, const struct field *f, char *base,
+			 int level);
+static int decode_numstr(struct bitstr *bs, const struct field *f, char *base,
+			 int level);
+static int decode_octstr(struct bitstr *bs, const struct field *f, char *base,
+			 int level);
+static int decode_bmpstr(struct bitstr *bs, const struct field *f, char *base,
+			 int level);
+static int decode_seq(struct bitstr *bs, const struct field *f, char *base,
+		      int level);
+static int decode_seqof(struct bitstr *bs, const struct field *f, char *base,
+			int level);
+static int decode_choice(struct bitstr *bs, const struct field *f, char *base,
+			 int level);
 
 /* Decoder Functions Vector */
-typedef int (*decoder_t)(bitstr_t *, const struct field_t *, char *, int);
+typedef int (*decoder_t)(struct bitstr *, const struct field *, char *, int);
 static const decoder_t Decoders[] = {
 	decode_nul,
 	decode_bool,
@@ -150,7 +162,7 @@ static const decoder_t Decoders[] = {
  * Functions
  ****************************************************************************/
 /* Assume bs is aligned && v < 16384 */
-static unsigned int get_len(bitstr_t *bs)
+static unsigned int get_len(struct bitstr *bs)
 {
 	unsigned int v;
 
@@ -166,7 +178,7 @@ static unsigned int get_len(bitstr_t *bs)
 }
 
 /****************************************************************************/
-static unsigned int get_bit(bitstr_t *bs)
+static unsigned int get_bit(struct bitstr *bs)
 {
 	unsigned int b = (*bs->cur) & (0x80 >> bs->bit);
 
@@ -177,7 +189,7 @@ static unsigned int get_bit(bitstr_t *bs)
 
 /****************************************************************************/
 /* Assume b <= 8 */
-static unsigned int get_bits(bitstr_t *bs, unsigned int b)
+static unsigned int get_bits(struct bitstr *bs, unsigned int b)
 {
 	unsigned int v, l;
 
@@ -203,7 +215,7 @@ static unsigned int get_bits(bitstr_t *bs, unsigned int b)
 
 /****************************************************************************/
 /* Assume b <= 32 */
-static unsigned int get_bitmap(bitstr_t *bs, unsigned int b)
+static unsigned int get_bitmap(struct bitstr *bs, unsigned int b)
 {
 	unsigned int v, l, shift, bytes;
 
@@ -242,7 +254,7 @@ static unsigned int get_bitmap(bitstr_t *bs, unsigned int b)
 /****************************************************************************
  * Assume bs is aligned and sizeof(unsigned int) == 4
  ****************************************************************************/
-static unsigned int get_uint(bitstr_t *bs, int b)
+static unsigned int get_uint(struct bitstr *bs, int b)
 {
 	unsigned int v = 0;
 
@@ -264,7 +276,7 @@ static unsigned int get_uint(bitstr_t *bs, int b)
 }
 
 /****************************************************************************/
-static int decode_nul(bitstr_t *bs, const struct field_t *f,
+static int decode_nul(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -273,7 +285,7 @@ static int decode_nul(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bool(bitstr_t *bs, const struct field_t *f,
+static int decode_bool(struct bitstr *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -285,7 +297,7 @@ static int decode_bool(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_oid(bitstr_t *bs, const struct field_t *f,
+static int decode_oid(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	int len;
@@ -302,7 +314,7 @@ static int decode_oid(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_int(bitstr_t *bs, const struct field_t *f,
+static int decode_int(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int len;
@@ -346,7 +358,7 @@ static int decode_int(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_enum(bitstr_t *bs, const struct field_t *f,
+static int decode_enum(struct bitstr *bs, const struct field *f,
                        char *base, int level)
 {
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -362,7 +374,7 @@ static int decode_enum(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
+static int decode_bitstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -396,7 +408,7 @@ static int decode_bitstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_numstr(bitstr_t *bs, const struct field_t *f,
+static int decode_numstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -414,7 +426,7 @@ static int decode_numstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_octstr(bitstr_t *bs, const struct field_t *f,
+static int decode_octstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -463,7 +475,7 @@ static int decode_octstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
+static int decode_bmpstr(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int len;
@@ -489,12 +501,12 @@ static int decode_bmpstr(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_seq(bitstr_t *bs, const struct field_t *f,
+static int decode_seq(struct bitstr *bs, const struct field *f,
                       char *base, int level)
 {
 	unsigned int ext, bmp, i, opt, len = 0, bmp2, bmp2_len;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -606,12 +618,12 @@ static int decode_seq(bitstr_t *bs, const struct field_t *f,
 }
 
 /****************************************************************************/
-static int decode_seqof(bitstr_t *bs, const struct field_t *f,
+static int decode_seqof(struct bitstr *bs, const struct field *f,
                         char *base, int level)
 {
 	unsigned int count, effective_count = 0, i, len = 0;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -696,12 +708,12 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
 
 
 /****************************************************************************/
-static int decode_choice(bitstr_t *bs, const struct field_t *f,
+static int decode_choice(struct bitstr *bs, const struct field *f,
                          char *base, int level)
 {
 	unsigned int type, ext, len = 0;
 	int err;
-	const struct field_t *son;
+	const struct field *son;
 	unsigned char *beg = NULL;
 
 	PRINT("%*.s%s\n", level * TAB_SIZE, " ", f->name);
@@ -768,11 +780,11 @@ static int decode_choice(bitstr_t *bs, const struct field_t *f,
 /****************************************************************************/
 int DecodeRasMessage(unsigned char *buf, size_t sz, RasMessage *ras)
 {
-	static const struct field_t ras_message = {
+	static const struct field ras_message = {
 		FNAME("RasMessage") CHOICE, 5, 24, 32, DECODE | EXT,
 		0, _RasMessage
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = bs.beg = bs.cur = buf;
 	bs.end = buf + sz;
@@ -785,11 +797,11 @@ int DecodeRasMessage(unsigned char *buf, size_t sz, RasMessage *ras)
 static int DecodeH323_UserInformation(unsigned char *buf, unsigned char *beg,
 				      size_t sz, H323_UserInformation *uuie)
 {
-	static const struct field_t h323_userinformation = {
+	static const struct field h323_userinformation = {
 		FNAME("H323-UserInformation") SEQ, 1, 2, 2, DECODE | EXT,
 		0, _H323_UserInformation
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = buf;
 	bs.beg = bs.cur = beg;
@@ -804,11 +816,11 @@ int DecodeMultimediaSystemControlMessage(unsigned char *buf, size_t sz,
 					 MultimediaSystemControlMessage *
 					 mscm)
 {
-	static const struct field_t multimediasystemcontrolmessage = {
+	static const struct field multimediasystemcontrolmessage = {
 		FNAME("MultimediaSystemControlMessage") CHOICE, 2, 4, 4,
 		DECODE | EXT, 0, _MultimediaSystemControlMessage
 	};
-	bitstr_t bs;
+	struct bitstr bs;
 
 	bs.buf = bs.beg = bs.cur = buf;
 	bs.end = buf + sz;
diff --git a/net/netfilter/nf_conntrack_h323_types.c b/net/netfilter/nf_conntrack_h323_types.c
index d880f35..70e5901 100644
--- a/net/netfilter/nf_conntrack_h323_types.c
+++ b/net/netfilter/nf_conntrack_h323_types.c
@@ -5,22 +5,22 @@
  * This source code is licensed under General Public License version 2.
  */
 
-static const struct field_t _TransportAddress_ipAddress[] = {	/* SEQUENCE */
+static const struct field _TransportAddress_ipAddress[] = {	/* SEQUENCE */
 	{FNAME("ip") OCTSTR, FIXD, 4, 0, DECODE,
 	 offsetof(TransportAddress_ipAddress, ip), NULL},
 	{FNAME("port") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TransportAddress_ipSourceRoute_route[] = {	/* SEQUENCE OF */
+static const struct field _TransportAddress_ipSourceRoute_route[] = {	/* SEQUENCE OF */
 	{FNAME("item") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TransportAddress_ipSourceRoute_routing[] = {	/* CHOICE */
+static const struct field _TransportAddress_ipSourceRoute_routing[] = {	/* CHOICE */
 	{FNAME("strict") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("loose") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TransportAddress_ipSourceRoute[] = {	/* SEQUENCE */
+static const struct field _TransportAddress_ipSourceRoute[] = {	/* SEQUENCE */
 	{FNAME("ip") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 	{FNAME("port") INT, WORD, 0, 0, SKIP, 0, NULL},
 	{FNAME("route") SEQOF, SEMI, 0, 0, SKIP, 0,
@@ -29,37 +29,37 @@ static const struct field_t _TransportAddress_ipSourceRoute[] = {	/* SEQUENCE */
 	 _TransportAddress_ipSourceRoute_routing},
 };
 
-static const struct field_t _TransportAddress_ipxAddress[] = {	/* SEQUENCE */
+static const struct field _TransportAddress_ipxAddress[] = {	/* SEQUENCE */
 	{FNAME("node") OCTSTR, FIXD, 6, 0, SKIP, 0, NULL},
 	{FNAME("netnum") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 	{FNAME("port") OCTSTR, FIXD, 2, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TransportAddress_ip6Address[] = {	/* SEQUENCE */
+static const struct field _TransportAddress_ip6Address[] = {	/* SEQUENCE */
 	{FNAME("ip") OCTSTR, FIXD, 16, 0, DECODE,
 	 offsetof(TransportAddress_ip6Address, ip), NULL},
 	{FNAME("port") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H221NonStandard[] = {	/* SEQUENCE */
+static const struct field _H221NonStandard[] = {	/* SEQUENCE */
 	{FNAME("t35CountryCode") INT, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("t35Extension") INT, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("manufacturerCode") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _NonStandardIdentifier[] = {	/* CHOICE */
+static const struct field _NonStandardIdentifier[] = {	/* CHOICE */
 	{FNAME("object") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("h221NonStandard") SEQ, 0, 3, 3, SKIP | EXT, 0,
 	 _H221NonStandard},
 };
 
-static const struct field_t _NonStandardParameter[] = {	/* SEQUENCE */
+static const struct field _NonStandardParameter[] = {	/* SEQUENCE */
 	{FNAME("nonStandardIdentifier") CHOICE, 1, 2, 2, SKIP | EXT, 0,
 	 _NonStandardIdentifier},
 	{FNAME("data") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TransportAddress[] = {	/* CHOICE */
+static const struct field _TransportAddress[] = {	/* CHOICE */
 	{FNAME("ipAddress") SEQ, 0, 2, 2, DECODE,
 	 offsetof(TransportAddress, ipAddress), _TransportAddress_ipAddress},
 	{FNAME("ipSourceRoute") SEQ, 0, 4, 4, SKIP | EXT, 0,
@@ -75,7 +75,7 @@ static const struct field_t _TransportAddress[] = {	/* CHOICE */
 	 _NonStandardParameter},
 };
 
-static const struct field_t _AliasAddress[] = {	/* CHOICE */
+static const struct field _AliasAddress[] = {	/* CHOICE */
 	{FNAME("dialedDigits") NUMDGT, 7, 1, 0, SKIP, 0, NULL},
 	{FNAME("h323-ID") BMPSTR, BYTE, 1, 0, SKIP, 0, NULL},
 	{FNAME("url-ID") IA5STR, WORD, 1, 0, SKIP, 0, NULL},
@@ -85,78 +85,78 @@ static const struct field_t _AliasAddress[] = {	/* CHOICE */
 	{FNAME("mobileUIM") CHOICE, 1, 2, 2, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _Setup_UUIE_sourceAddress[] = {	/* SEQUENCE OF */
+static const struct field _Setup_UUIE_sourceAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _VendorIdentifier[] = {	/* SEQUENCE */
+static const struct field _VendorIdentifier[] = {	/* SEQUENCE */
 	{FNAME("vendor") SEQ, 0, 3, 3, SKIP | EXT, 0, _H221NonStandard},
 	{FNAME("productId") OCTSTR, BYTE, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("versionId") OCTSTR, BYTE, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _GatekeeperInfo[] = {	/* SEQUENCE */
+static const struct field _GatekeeperInfo[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 };
 
-static const struct field_t _H310Caps[] = {	/* SEQUENCE */
+static const struct field _H310Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H320Caps[] = {	/* SEQUENCE */
+static const struct field _H320Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H321Caps[] = {	/* SEQUENCE */
+static const struct field _H321Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H322Caps[] = {	/* SEQUENCE */
+static const struct field _H322Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H323Caps[] = {	/* SEQUENCE */
+static const struct field _H323Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H324Caps[] = {	/* SEQUENCE */
+static const struct field _H324Caps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _VoiceCaps[] = {	/* SEQUENCE */
+static const struct field _VoiceCaps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _T120OnlyCaps[] = {	/* SEQUENCE */
+static const struct field _T120OnlyCaps[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("dataRatesSupported") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("supportedPrefixes") SEQOF, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _SupportedProtocols[] = {	/* CHOICE */
+static const struct field _SupportedProtocols[] = {	/* CHOICE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP, 0,
 	 _NonStandardParameter},
 	{FNAME("h310") SEQ, 1, 1, 3, SKIP | EXT, 0, _H310Caps},
@@ -171,29 +171,29 @@ static const struct field_t _SupportedProtocols[] = {	/* CHOICE */
 	{FNAME("t38FaxAnnexbOnly") SEQ, 2, 5, 5, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _GatewayInfo_protocol[] = {	/* SEQUENCE OF */
+static const struct field _GatewayInfo_protocol[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 4, 9, 11, SKIP | EXT, 0, _SupportedProtocols},
 };
 
-static const struct field_t _GatewayInfo[] = {	/* SEQUENCE */
+static const struct field _GatewayInfo[] = {	/* SEQUENCE */
 	{FNAME("protocol") SEQOF, SEMI, 0, 0, SKIP | OPT, 0,
 	 _GatewayInfo_protocol},
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 };
 
-static const struct field_t _McuInfo[] = {	/* SEQUENCE */
+static const struct field _McuInfo[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("protocol") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _TerminalInfo[] = {	/* SEQUENCE */
+static const struct field _TerminalInfo[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 };
 
-static const struct field_t _EndpointType[] = {	/* SEQUENCE */
+static const struct field _EndpointType[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("vendor") SEQ, 2, 3, 3, SKIP | EXT | OPT, 0,
@@ -210,19 +210,19 @@ static const struct field_t _EndpointType[] = {	/* SEQUENCE */
 	 0, NULL},
 };
 
-static const struct field_t _Setup_UUIE_destinationAddress[] = {	/* SEQUENCE OF */
+static const struct field _Setup_UUIE_destinationAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _Setup_UUIE_destExtraCallInfo[] = {	/* SEQUENCE OF */
+static const struct field _Setup_UUIE_destExtraCallInfo[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _Setup_UUIE_destExtraCRV[] = {	/* SEQUENCE OF */
+static const struct field _Setup_UUIE_destExtraCRV[] = {	/* SEQUENCE OF */
 	{FNAME("item") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _Setup_UUIE_conferenceGoal[] = {	/* CHOICE */
+static const struct field _Setup_UUIE_conferenceGoal[] = {	/* CHOICE */
 	{FNAME("create") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("join") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("invite") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -231,12 +231,12 @@ static const struct field_t _Setup_UUIE_conferenceGoal[] = {	/* CHOICE */
 	 0, NULL},
 };
 
-static const struct field_t _Q954Details[] = {	/* SEQUENCE */
+static const struct field _Q954Details[] = {	/* SEQUENCE */
 	{FNAME("conferenceCalling") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("threePartyService") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _QseriesOptions[] = {	/* SEQUENCE */
+static const struct field _QseriesOptions[] = {	/* SEQUENCE */
 	{FNAME("q932Full") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("q951Full") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("q952Full") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -247,32 +247,32 @@ static const struct field_t _QseriesOptions[] = {	/* SEQUENCE */
 	{FNAME("q954Info") SEQ, 0, 2, 2, SKIP | EXT, 0, _Q954Details},
 };
 
-static const struct field_t _CallType[] = {	/* CHOICE */
+static const struct field _CallType[] = {	/* CHOICE */
 	{FNAME("pointToPoint") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("oneToN") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("nToOne") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("nToN") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H245_NonStandardIdentifier_h221NonStandard[] = {	/* SEQUENCE */
+static const struct field _H245_NonStandardIdentifier_h221NonStandard[] = {	/* SEQUENCE */
 	{FNAME("t35CountryCode") INT, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("t35Extension") INT, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("manufacturerCode") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H245_NonStandardIdentifier[] = {	/* CHOICE */
+static const struct field _H245_NonStandardIdentifier[] = {	/* CHOICE */
 	{FNAME("object") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("h221NonStandard") SEQ, 0, 3, 3, SKIP, 0,
 	 _H245_NonStandardIdentifier_h221NonStandard},
 };
 
-static const struct field_t _H245_NonStandardParameter[] = {	/* SEQUENCE */
+static const struct field _H245_NonStandardParameter[] = {	/* SEQUENCE */
 	{FNAME("nonStandardIdentifier") CHOICE, 1, 2, 2, SKIP, 0,
 	 _H245_NonStandardIdentifier},
 	{FNAME("data") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H261VideoCapability[] = {	/* SEQUENCE */
+static const struct field _H261VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("qcifMPI") INT, 2, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("cifMPI") INT, 2, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("temporalSpatialTradeOffCapability") BOOL, FIXD, 0, 0, SKIP, 0,
@@ -282,7 +282,7 @@ static const struct field_t _H261VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("videoBadMBsCap") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H262VideoCapability[] = {	/* SEQUENCE */
+static const struct field _H262VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("profileAndLevel-SPatML") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("profileAndLevel-MPatLL") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("profileAndLevel-MPatML") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -304,7 +304,7 @@ static const struct field_t _H262VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("videoBadMBsCap") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H263VideoCapability[] = {	/* SEQUENCE */
+static const struct field _H263VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("sqcifMPI") INT, 5, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("qcifMPI") INT, 5, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("cifMPI") INT, 5, 1, 0, SKIP | OPT, 0, NULL},
@@ -330,7 +330,7 @@ static const struct field_t _H263VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("h263Options") SEQ, 5, 29, 31, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _IS11172VideoCapability[] = {	/* SEQUENCE */
+static const struct field _IS11172VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("constrainedBitstream") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("videoBitRate") INT, CONS, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("vbvBufferSize") INT, CONS, 0, 0, SKIP | OPT, 0, NULL},
@@ -341,7 +341,7 @@ static const struct field_t _IS11172VideoCapability[] = {	/* SEQUENCE */
 	{FNAME("videoBadMBsCap") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _VideoCapability[] = {	/* CHOICE */
+static const struct field _VideoCapability[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("h261VideoCapability") SEQ, 2, 5, 6, SKIP | EXT, 0,
@@ -355,12 +355,12 @@ static const struct field_t _VideoCapability[] = {	/* CHOICE */
 	{FNAME("genericVideoCapability") SEQ, 5, 6, 6, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _AudioCapability_g7231[] = {	/* SEQUENCE */
+static const struct field _AudioCapability_g7231[] = {	/* SEQUENCE */
 	{FNAME("maxAl-sduAudioFrames") INT, BYTE, 1, 0, SKIP, 0, NULL},
 	{FNAME("silenceSuppression") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _IS11172AudioCapability[] = {	/* SEQUENCE */
+static const struct field _IS11172AudioCapability[] = {	/* SEQUENCE */
 	{FNAME("audioLayer1") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("audioLayer2") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("audioLayer3") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -372,7 +372,7 @@ static const struct field_t _IS11172AudioCapability[] = {	/* SEQUENCE */
 	{FNAME("bitRate") INT, WORD, 1, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _IS13818AudioCapability[] = {	/* SEQUENCE */
+static const struct field _IS13818AudioCapability[] = {	/* SEQUENCE */
 	{FNAME("audioLayer1") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("audioLayer2") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("audioLayer3") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -396,7 +396,7 @@ static const struct field_t _IS13818AudioCapability[] = {	/* SEQUENCE */
 	{FNAME("bitRate") INT, WORD, 1, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _AudioCapability[] = {	/* CHOICE */
+static const struct field _AudioCapability[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("g711Alaw64k") INT, BYTE, 1, 0, SKIP, 0, NULL},
@@ -424,7 +424,7 @@ static const struct field_t _AudioCapability[] = {	/* CHOICE */
 	{FNAME("g729Extensions") SEQ, 1, 8, 8, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _DataProtocolCapability[] = {	/* CHOICE */
+static const struct field _DataProtocolCapability[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("v14buffered") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -442,7 +442,7 @@ static const struct field_t _DataProtocolCapability[] = {	/* CHOICE */
 	{FNAME("udp") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _T84Profile_t84Restricted[] = {	/* SEQUENCE */
+static const struct field _T84Profile_t84Restricted[] = {	/* SEQUENCE */
 	{FNAME("qcif") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("cif") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("ccir601Seq") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -464,25 +464,25 @@ static const struct field_t _T84Profile_t84Restricted[] = {	/* SEQUENCE */
 	{FNAME("digPhotoHighProg") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _T84Profile[] = {	/* CHOICE */
+static const struct field _T84Profile[] = {	/* CHOICE */
 	{FNAME("t84Unrestricted") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("t84Restricted") SEQ, 0, 19, 19, SKIP | EXT, 0,
 	 _T84Profile_t84Restricted},
 };
 
-static const struct field_t _DataApplicationCapability_application_t84[] = {	/* SEQUENCE */
+static const struct field _DataApplicationCapability_application_t84[] = {	/* SEQUENCE */
 	{FNAME("t84Protocol") CHOICE, 3, 7, 14, SKIP | EXT, 0,
 	 _DataProtocolCapability},
 	{FNAME("t84Profile") CHOICE, 1, 2, 2, SKIP, 0, _T84Profile},
 };
 
-static const struct field_t _DataApplicationCapability_application_nlpid[] = {	/* SEQUENCE */
+static const struct field _DataApplicationCapability_application_nlpid[] = {	/* SEQUENCE */
 	{FNAME("nlpidProtocol") CHOICE, 3, 7, 14, SKIP | EXT, 0,
 	 _DataProtocolCapability},
 	{FNAME("nlpidData") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _DataApplicationCapability_application[] = {	/* CHOICE */
+static const struct field _DataApplicationCapability_application[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("t120") CHOICE, 3, 7, 14, DECODE | EXT,
@@ -509,20 +509,20 @@ static const struct field_t _DataApplicationCapability_application[] = {	/* CHOI
 	{FNAME("genericDataCapability") SEQ, 5, 6, 6, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _DataApplicationCapability[] = {	/* SEQUENCE */
+static const struct field _DataApplicationCapability[] = {	/* SEQUENCE */
 	{FNAME("application") CHOICE, 4, 10, 14, DECODE | EXT,
 	 offsetof(DataApplicationCapability, application),
 	 _DataApplicationCapability_application},
 	{FNAME("maxBitRate") INT, CONS, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _EncryptionMode[] = {	/* CHOICE */
+static const struct field _EncryptionMode[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("h233Encryption") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _DataType[] = {	/* CHOICE */
+static const struct field _DataType[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("nullData") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -538,7 +538,7 @@ static const struct field_t _DataType[] = {	/* CHOICE */
 	{FNAME("multiplexedStream") SEQ, 0, 2, 2, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _H222LogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _H222LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("resourceID") INT, WORD, 0, 0, SKIP, 0, NULL},
 	{FNAME("subChannelID") INT, WORD, 0, 0, SKIP, 0, NULL},
 	{FNAME("pcr-pid") INT, WORD, 0, 0, SKIP | OPT, 0, NULL},
@@ -546,12 +546,12 @@ static const struct field_t _H222LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("streamDescriptors") OCTSTR, SEMI, 0, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _H223LogicalChannelParameters_adaptationLayerType_al3[] = {	/* SEQUENCE */
+static const struct field _H223LogicalChannelParameters_adaptationLayerType_al3[] = {	/* SEQUENCE */
 	{FNAME("controlFieldOctets") INT, 2, 0, 0, SKIP, 0, NULL},
 	{FNAME("sendBufferSize") INT, CONS, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H223LogicalChannelParameters_adaptationLayerType[] = {	/* CHOICE */
+static const struct field _H223LogicalChannelParameters_adaptationLayerType[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0,
 	 _H245_NonStandardParameter},
 	{FNAME("al1Framed") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -565,53 +565,53 @@ static const struct field_t _H223LogicalChannelParameters_adaptationLayerType[]
 	{FNAME("al3M") SEQ, 0, 5, 6, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _H223LogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _H223LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("adaptationLayerType") CHOICE, 3, 6, 9, SKIP | EXT, 0,
 	 _H223LogicalChannelParameters_adaptationLayerType},
 	{FNAME("segmentableFlag") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CRCLength[] = {	/* CHOICE */
+static const struct field _CRCLength[] = {	/* CHOICE */
 	{FNAME("crc8bit") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("crc16bit") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("crc32bit") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V76HDLCParameters[] = {	/* SEQUENCE */
+static const struct field _V76HDLCParameters[] = {	/* SEQUENCE */
 	{FNAME("crcLength") CHOICE, 2, 3, 3, SKIP | EXT, 0, _CRCLength},
 	{FNAME("n401") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("loopbackTestProcedure") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V76LogicalChannelParameters_suspendResume[] = {	/* CHOICE */
+static const struct field _V76LogicalChannelParameters_suspendResume[] = {	/* CHOICE */
 	{FNAME("noSuspendResume") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("suspendResumewAddress") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("suspendResumewoAddress") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V76LogicalChannelParameters_mode_eRM_recovery[] = {	/* CHOICE */
+static const struct field _V76LogicalChannelParameters_mode_eRM_recovery[] = {	/* CHOICE */
 	{FNAME("rej") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("sREJ") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("mSREJ") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V76LogicalChannelParameters_mode_eRM[] = {	/* SEQUENCE */
+static const struct field _V76LogicalChannelParameters_mode_eRM[] = {	/* SEQUENCE */
 	{FNAME("windowSize") INT, 7, 1, 0, SKIP, 0, NULL},
 	{FNAME("recovery") CHOICE, 2, 3, 3, SKIP | EXT, 0,
 	 _V76LogicalChannelParameters_mode_eRM_recovery},
 };
 
-static const struct field_t _V76LogicalChannelParameters_mode[] = {	/* CHOICE */
+static const struct field _V76LogicalChannelParameters_mode[] = {	/* CHOICE */
 	{FNAME("eRM") SEQ, 0, 2, 2, SKIP | EXT, 0,
 	 _V76LogicalChannelParameters_mode_eRM},
 	{FNAME("uNERM") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V75Parameters[] = {	/* SEQUENCE */
+static const struct field _V75Parameters[] = {	/* SEQUENCE */
 	{FNAME("audioHeaderPresent") BOOL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _V76LogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _V76LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("hdlcParameters") SEQ, 0, 3, 3, SKIP | EXT, 0,
 	 _V76HDLCParameters},
 	{FNAME("suspendResume") CHOICE, 2, 3, 3, SKIP | EXT, 0,
@@ -622,38 +622,38 @@ static const struct field_t _V76LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("v75Parameters") SEQ, 0, 1, 1, SKIP | EXT, 0, _V75Parameters},
 };
 
-static const struct field_t _H2250LogicalChannelParameters_nonStandard[] = {	/* SEQUENCE OF */
+static const struct field _H2250LogicalChannelParameters_nonStandard[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 0, 2, 2, SKIP, 0, _H245_NonStandardParameter},
 };
 
-static const struct field_t _UnicastAddress_iPAddress[] = {	/* SEQUENCE */
+static const struct field _UnicastAddress_iPAddress[] = {	/* SEQUENCE */
 	{FNAME("network") OCTSTR, FIXD, 4, 0, DECODE,
 	 offsetof(UnicastAddress_iPAddress, network), NULL},
 	{FNAME("tsapIdentifier") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _UnicastAddress_iPXAddress[] = {	/* SEQUENCE */
+static const struct field _UnicastAddress_iPXAddress[] = {	/* SEQUENCE */
 	{FNAME("node") OCTSTR, FIXD, 6, 0, SKIP, 0, NULL},
 	{FNAME("netnum") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 	{FNAME("tsapIdentifier") OCTSTR, FIXD, 2, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _UnicastAddress_iP6Address[] = {	/* SEQUENCE */
+static const struct field _UnicastAddress_iP6Address[] = {	/* SEQUENCE */
 	{FNAME("network") OCTSTR, FIXD, 16, 0, DECODE,
 	 offsetof(UnicastAddress_iP6Address, network), NULL},
 	{FNAME("tsapIdentifier") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _UnicastAddress_iPSourceRouteAddress_routing[] = {	/* CHOICE */
+static const struct field _UnicastAddress_iPSourceRouteAddress_routing[] = {	/* CHOICE */
 	{FNAME("strict") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("loose") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _UnicastAddress_iPSourceRouteAddress_route[] = {	/* SEQUENCE OF */
+static const struct field _UnicastAddress_iPSourceRouteAddress_route[] = {	/* SEQUENCE OF */
 	{FNAME("item") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _UnicastAddress_iPSourceRouteAddress[] = {	/* SEQUENCE */
+static const struct field _UnicastAddress_iPSourceRouteAddress[] = {	/* SEQUENCE */
 	{FNAME("routing") CHOICE, 1, 2, 2, SKIP, 0,
 	 _UnicastAddress_iPSourceRouteAddress_routing},
 	{FNAME("network") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
@@ -662,7 +662,7 @@ static const struct field_t _UnicastAddress_iPSourceRouteAddress[] = {	/* SEQUEN
 	 _UnicastAddress_iPSourceRouteAddress_route},
 };
 
-static const struct field_t _UnicastAddress[] = {	/* CHOICE */
+static const struct field _UnicastAddress[] = {	/* CHOICE */
 	{FNAME("iPAddress") SEQ, 0, 2, 2, DECODE | EXT,
 	 offsetof(UnicastAddress, iPAddress), _UnicastAddress_iPAddress},
 	{FNAME("iPXAddress") SEQ, 0, 3, 3, SKIP | EXT, 0,
@@ -676,17 +676,17 @@ static const struct field_t _UnicastAddress[] = {	/* CHOICE */
 	{FNAME("nonStandardAddress") SEQ, 0, 2, 2, SKIP, 0, NULL},
 };
 
-static const struct field_t _MulticastAddress_iPAddress[] = {	/* SEQUENCE */
+static const struct field _MulticastAddress_iPAddress[] = {	/* SEQUENCE */
 	{FNAME("network") OCTSTR, FIXD, 4, 0, SKIP, 0, NULL},
 	{FNAME("tsapIdentifier") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _MulticastAddress_iP6Address[] = {	/* SEQUENCE */
+static const struct field _MulticastAddress_iP6Address[] = {	/* SEQUENCE */
 	{FNAME("network") OCTSTR, FIXD, 16, 0, SKIP, 0, NULL},
 	{FNAME("tsapIdentifier") INT, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _MulticastAddress[] = {	/* CHOICE */
+static const struct field _MulticastAddress[] = {	/* CHOICE */
 	{FNAME("iPAddress") SEQ, 0, 2, 2, SKIP | EXT, 0,
 	 _MulticastAddress_iPAddress},
 	{FNAME("iP6Address") SEQ, 0, 2, 2, SKIP | EXT, 0,
@@ -695,14 +695,14 @@ static const struct field_t _MulticastAddress[] = {	/* CHOICE */
 	{FNAME("nonStandardAddress") SEQ, 0, 2, 2, SKIP, 0, NULL},
 };
 
-static const struct field_t _H245_TransportAddress[] = {	/* CHOICE */
+static const struct field _H245_TransportAddress[] = {	/* CHOICE */
 	{FNAME("unicastAddress") CHOICE, 3, 5, 7, DECODE | EXT,
 	 offsetof(H245_TransportAddress, unicastAddress), _UnicastAddress},
 	{FNAME("multicastAddress") CHOICE, 1, 2, 4, SKIP | EXT, 0,
 	 _MulticastAddress},
 };
 
-static const struct field_t _H2250LogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _H2250LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("nonStandard") SEQOF, SEMI, 0, 0, SKIP | OPT, 0,
 	 _H2250LogicalChannelParameters_nonStandard},
 	{FNAME("sessionID") INT, BYTE, 0, 0, SKIP, 0, NULL},
@@ -728,7 +728,7 @@ static const struct field_t _H2250LogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("source") SEQ, 0, 2, 2, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _OpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
+static const struct field _OpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
 	{FNAME("h222LogicalChannelParameters") SEQ, 3, 5, 5, SKIP | EXT, 0,
 	 _H222LogicalChannelParameters},
 	{FNAME("h223LogicalChannelParameters") SEQ, 0, 2, 2, SKIP | EXT, 0,
@@ -742,7 +742,7 @@ static const struct field_t _OpenLogicalChannel_forwardLogicalChannelParameters_
 	{FNAME("none") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _OpenLogicalChannel_forwardLogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _OpenLogicalChannel_forwardLogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("portNumber") INT, WORD, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("dataType") CHOICE, 3, 6, 9, DECODE | EXT,
 	 offsetof(OpenLogicalChannel_forwardLogicalChannelParameters,
@@ -756,7 +756,7 @@ static const struct field_t _OpenLogicalChannel_forwardLogicalChannelParameters[
 	{FNAME("replacementFor") INT, WORD, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _OpenLogicalChannel_reverseLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
+static const struct field _OpenLogicalChannel_reverseLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
 	{FNAME("h223LogicalChannelParameters") SEQ, 0, 2, 2, SKIP | EXT, 0,
 	 _H223LogicalChannelParameters},
 	{FNAME("v76LogicalChannelParameters") SEQ, 0, 5, 5, SKIP | EXT, 0,
@@ -767,7 +767,7 @@ static const struct field_t _OpenLogicalChannel_reverseLogicalChannelParameters_
 	  h2250LogicalChannelParameters), _H2250LogicalChannelParameters},
 };
 
-static const struct field_t _OpenLogicalChannel_reverseLogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _OpenLogicalChannel_reverseLogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("dataType") CHOICE, 3, 6, 9, SKIP | EXT, 0, _DataType},
 	{FNAME("multiplexParameters") CHOICE, 1, 2, 3, DECODE | EXT | OPT,
 	 offsetof(OpenLogicalChannel_reverseLogicalChannelParameters,
@@ -778,23 +778,23 @@ static const struct field_t _OpenLogicalChannel_reverseLogicalChannelParameters[
 	{FNAME("replacementFor") INT, WORD, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _NetworkAccessParameters_distribution[] = {	/* CHOICE */
+static const struct field _NetworkAccessParameters_distribution[] = {	/* CHOICE */
 	{FNAME("unicast") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("multicast") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _Q2931Address_address[] = {	/* CHOICE */
+static const struct field _Q2931Address_address[] = {	/* CHOICE */
 	{FNAME("internationalNumber") NUMSTR, 4, 1, 0, SKIP, 0, NULL},
 	{FNAME("nsapAddress") OCTSTR, 5, 1, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _Q2931Address[] = {	/* SEQUENCE */
+static const struct field _Q2931Address[] = {	/* SEQUENCE */
 	{FNAME("address") CHOICE, 1, 2, 2, SKIP | EXT, 0,
 	 _Q2931Address_address},
 	{FNAME("subaddress") OCTSTR, 5, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _NetworkAccessParameters_networkAddress[] = {	/* CHOICE */
+static const struct field _NetworkAccessParameters_networkAddress[] = {	/* CHOICE */
 	{FNAME("q2931Address") SEQ, 1, 2, 2, SKIP | EXT, 0, _Q2931Address},
 	{FNAME("e164Address") NUMDGT, 7, 1, 0, SKIP, 0, NULL},
 	{FNAME("localAreaAddress") CHOICE, 1, 2, 2, DECODE | EXT,
@@ -802,7 +802,7 @@ static const struct field_t _NetworkAccessParameters_networkAddress[] = {	/* CHO
 	 _H245_TransportAddress},
 };
 
-static const struct field_t _NetworkAccessParameters[] = {	/* SEQUENCE */
+static const struct field _NetworkAccessParameters[] = {	/* SEQUENCE */
 	{FNAME("distribution") CHOICE, 1, 2, 2, SKIP | EXT | OPT, 0,
 	 _NetworkAccessParameters_distribution},
 	{FNAME("networkAddress") CHOICE, 2, 3, 3, DECODE | EXT,
@@ -814,7 +814,7 @@ static const struct field_t _NetworkAccessParameters[] = {	/* SEQUENCE */
 	 NULL},
 };
 
-static const struct field_t _OpenLogicalChannel[] = {	/* SEQUENCE */
+static const struct field _OpenLogicalChannel[] = {	/* SEQUENCE */
 	{FNAME("forwardLogicalChannelNumber") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("forwardLogicalChannelParameters") SEQ, 1, 3, 5, DECODE | EXT,
 	 offsetof(OpenLogicalChannel, forwardLogicalChannelParameters),
@@ -829,13 +829,13 @@ static const struct field_t _OpenLogicalChannel[] = {	/* SEQUENCE */
 	{FNAME("encryptionSync") SEQ, 2, 4, 4, STOP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _Setup_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _Setup_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _Setup_UUIE[] = {	/* SEQUENCE */
+static const struct field _Setup_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("h245Address") CHOICE, 3, 7, 7, DECODE | EXT | OPT,
 	 offsetof(Setup_UUIE, h245Address), _TransportAddress},
@@ -894,13 +894,13 @@ static const struct field_t _Setup_UUIE[] = {	/* SEQUENCE */
 	 NULL},
 };
 
-static const struct field_t _CallProceeding_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _CallProceeding_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _CallProceeding_UUIE[] = {	/* SEQUENCE */
+static const struct field _CallProceeding_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("destinationInfo") SEQ, 6, 8, 10, SKIP | EXT, 0,
 	 _EndpointType},
@@ -920,13 +920,13 @@ static const struct field_t _CallProceeding_UUIE[] = {	/* SEQUENCE */
 	{FNAME("featureSet") SEQ, 3, 4, 4, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _Connect_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _Connect_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _Connect_UUIE[] = {	/* SEQUENCE */
+static const struct field _Connect_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("h245Address") CHOICE, 3, 7, 7, DECODE | EXT | OPT,
 	 offsetof(Connect_UUIE, h245Address), _TransportAddress},
@@ -954,13 +954,13 @@ static const struct field_t _Connect_UUIE[] = {	/* SEQUENCE */
 	{FNAME("featureSet") SEQ, 3, 4, 4, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _Alerting_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _Alerting_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _Alerting_UUIE[] = {	/* SEQUENCE */
+static const struct field _Alerting_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("destinationInfo") SEQ, 6, 8, 10, SKIP | EXT, 0,
 	 _EndpointType},
@@ -986,7 +986,7 @@ static const struct field_t _Alerting_UUIE[] = {	/* SEQUENCE */
 	{FNAME("featureSet") SEQ, 3, 4, 4, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _Information_UUIE[] = {	/* SEQUENCE */
+static const struct field _Information_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("callIdentifier") SEQ, 0, 1, 1, SKIP | EXT, 0, NULL},
 	{FNAME("tokens") SEQOF, SEMI, 0, 0, SKIP | OPT, 0, NULL},
@@ -996,7 +996,7 @@ static const struct field_t _Information_UUIE[] = {	/* SEQUENCE */
 	{FNAME("circuitInfo") SEQ, 3, 3, 3, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _ReleaseCompleteReason[] = {	/* CHOICE */
+static const struct field _ReleaseCompleteReason[] = {	/* CHOICE */
 	{FNAME("noBandwidth") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("gatekeeperResources") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("unreachableDestination") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -1022,7 +1022,7 @@ static const struct field_t _ReleaseCompleteReason[] = {	/* CHOICE */
 	{FNAME("tunnelledSignallingRejected") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _ReleaseComplete_UUIE[] = {	/* SEQUENCE */
+static const struct field _ReleaseComplete_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("reason") CHOICE, 4, 12, 22, SKIP | EXT | OPT, 0,
 	 _ReleaseCompleteReason},
@@ -1039,11 +1039,11 @@ static const struct field_t _ReleaseComplete_UUIE[] = {	/* SEQUENCE */
 	{FNAME("featureSet") SEQ, 3, 4, 4, SKIP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _Facility_UUIE_alternativeAliasAddress[] = {	/* SEQUENCE OF */
+static const struct field _Facility_UUIE_alternativeAliasAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _FacilityReason[] = {	/* CHOICE */
+static const struct field _FacilityReason[] = {	/* CHOICE */
 	{FNAME("routeCallToGatekeeper") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("callForwarded") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("routeCallToMC") NUL, FIXD, 0, 0, SKIP, 0, NULL},
@@ -1057,13 +1057,13 @@ static const struct field_t _FacilityReason[] = {	/* CHOICE */
 	{FNAME("transportedInformation") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _Facility_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _Facility_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _Facility_UUIE[] = {	/* SEQUENCE */
+static const struct field _Facility_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("alternativeAddress") CHOICE, 3, 7, 7, DECODE | EXT | OPT,
 	 offsetof(Facility_UUIE, alternativeAddress), _TransportAddress},
@@ -1094,17 +1094,17 @@ static const struct field_t _Facility_UUIE[] = {	/* SEQUENCE */
 	 NULL},
 };
 
-static const struct field_t _CallIdentifier[] = {	/* SEQUENCE */
+static const struct field _CallIdentifier[] = {	/* SEQUENCE */
 	{FNAME("guid") OCTSTR, FIXD, 16, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _SecurityServiceMode[] = {	/* CHOICE */
+static const struct field _SecurityServiceMode[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0, _NonStandardParameter},
 	{FNAME("none") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("default") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _SecurityCapabilities[] = {	/* SEQUENCE */
+static const struct field _SecurityCapabilities[] = {	/* SEQUENCE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("encryption") CHOICE, 2, 3, 3, SKIP | EXT, 0,
@@ -1115,30 +1115,30 @@ static const struct field_t _SecurityCapabilities[] = {	/* SEQUENCE */
 	 _SecurityServiceMode},
 };
 
-static const struct field_t _H245Security[] = {	/* CHOICE */
+static const struct field _H245Security[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 2, 2, SKIP, 0, _NonStandardParameter},
 	{FNAME("noSecurity") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("tls") SEQ, 1, 4, 4, SKIP | EXT, 0, _SecurityCapabilities},
 	{FNAME("ipsec") SEQ, 1, 4, 4, SKIP | EXT, 0, _SecurityCapabilities},
 };
 
-static const struct field_t _DHset[] = {	/* SEQUENCE */
+static const struct field _DHset[] = {	/* SEQUENCE */
 	{FNAME("halfkey") BITSTR, WORD, 0, 0, SKIP, 0, NULL},
 	{FNAME("modSize") BITSTR, WORD, 0, 0, SKIP, 0, NULL},
 	{FNAME("generator") BITSTR, WORD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _TypedCertificate[] = {	/* SEQUENCE */
+static const struct field _TypedCertificate[] = {	/* SEQUENCE */
 	{FNAME("type") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("certificate") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _H235_NonStandardParameter[] = {	/* SEQUENCE */
+static const struct field _H235_NonStandardParameter[] = {	/* SEQUENCE */
 	{FNAME("nonStandardIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("data") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _ClearToken[] = {	/* SEQUENCE */
+static const struct field _ClearToken[] = {	/* SEQUENCE */
 	{FNAME("tokenOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("timeStamp") INT, CONS, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("password") BMPSTR, 7, 1, 0, SKIP | OPT, 0, NULL},
@@ -1154,120 +1154,120 @@ static const struct field_t _ClearToken[] = {	/* SEQUENCE */
 	{FNAME("sendersID") BMPSTR, 7, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _Progress_UUIE_tokens[] = {	/* SEQUENCE OF */
+static const struct field _Progress_UUIE_tokens[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 8, 9, 11, SKIP | EXT, 0, _ClearToken},
 };
 
-static const struct field_t _Params[] = {	/* SEQUENCE */
+static const struct field _Params[] = {	/* SEQUENCE */
 	{FNAME("ranInt") INT, UNCO, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("iv8") OCTSTR, FIXD, 8, 0, SKIP | OPT, 0, NULL},
 	{FNAME("iv16") OCTSTR, FIXD, 16, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoEPPwdHash_token[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoEPPwdHash_token[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("hash") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoEPPwdHash[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoEPPwdHash[] = {	/* SEQUENCE */
 	{FNAME("alias") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 	{FNAME("timeStamp") INT, CONS, 1, 0, SKIP, 0, NULL},
 	{FNAME("token") SEQ, 0, 3, 3, SKIP, 0,
 	 _CryptoH323Token_cryptoEPPwdHash_token},
 };
 
-static const struct field_t _CryptoH323Token_cryptoGKPwdHash_token[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoGKPwdHash_token[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("hash") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoGKPwdHash[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoGKPwdHash[] = {	/* SEQUENCE */
 	{FNAME("gatekeeperId") BMPSTR, 7, 1, 0, SKIP, 0, NULL},
 	{FNAME("timeStamp") INT, CONS, 1, 0, SKIP, 0, NULL},
 	{FNAME("token") SEQ, 0, 3, 3, SKIP, 0,
 	 _CryptoH323Token_cryptoGKPwdHash_token},
 };
 
-static const struct field_t _CryptoH323Token_cryptoEPPwdEncr[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoEPPwdEncr[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("encryptedData") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoGKPwdEncr[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoGKPwdEncr[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("encryptedData") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoEPCert[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoEPCert[] = {	/* SEQUENCE */
 	{FNAME("toBeSigned") SEQ, 8, 9, 11, SKIP | OPEN | EXT, 0, NULL},
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("signature") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoGKCert[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoGKCert[] = {	/* SEQUENCE */
 	{FNAME("toBeSigned") SEQ, 8, 9, 11, SKIP | OPEN | EXT, 0, NULL},
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("signature") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoH323Token_cryptoFastStart[] = {	/* SEQUENCE */
+static const struct field _CryptoH323Token_cryptoFastStart[] = {	/* SEQUENCE */
 	{FNAME("toBeSigned") SEQ, 8, 9, 11, SKIP | OPEN | EXT, 0, NULL},
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("signature") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoToken_cryptoEncryptedToken_token[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoEncryptedToken_token[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("encryptedData") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoToken_cryptoEncryptedToken[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoEncryptedToken[] = {	/* SEQUENCE */
 	{FNAME("tokenOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("token") SEQ, 0, 3, 3, SKIP, 0,
 	 _CryptoToken_cryptoEncryptedToken_token},
 };
 
-static const struct field_t _CryptoToken_cryptoSignedToken_token[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoSignedToken_token[] = {	/* SEQUENCE */
 	{FNAME("toBeSigned") SEQ, 8, 9, 11, SKIP | OPEN | EXT, 0, NULL},
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("signature") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoToken_cryptoSignedToken[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoSignedToken[] = {	/* SEQUENCE */
 	{FNAME("tokenOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("token") SEQ, 0, 4, 4, SKIP, 0,
 	 _CryptoToken_cryptoSignedToken_token},
 };
 
-static const struct field_t _CryptoToken_cryptoHashedToken_token[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoHashedToken_token[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("hash") BITSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoToken_cryptoHashedToken[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoHashedToken[] = {	/* SEQUENCE */
 	{FNAME("tokenOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("hashedVals") SEQ, 8, 9, 11, SKIP | EXT, 0, _ClearToken},
 	{FNAME("token") SEQ, 0, 3, 3, SKIP, 0,
 	 _CryptoToken_cryptoHashedToken_token},
 };
 
-static const struct field_t _CryptoToken_cryptoPwdEncr[] = {	/* SEQUENCE */
+static const struct field _CryptoToken_cryptoPwdEncr[] = {	/* SEQUENCE */
 	{FNAME("algorithmOID") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("paramS") SEQ, 2, 2, 3, SKIP | EXT, 0, _Params},
 	{FNAME("encryptedData") OCTSTR, SEMI, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _CryptoToken[] = {	/* CHOICE */
+static const struct field _CryptoToken[] = {	/* CHOICE */
 	{FNAME("cryptoEncryptedToken") SEQ, 0, 2, 2, SKIP, 0,
 	 _CryptoToken_cryptoEncryptedToken},
 	{FNAME("cryptoSignedToken") SEQ, 0, 2, 2, SKIP, 0,
@@ -1278,7 +1278,7 @@ static const struct field_t _CryptoToken[] = {	/* CHOICE */
 	 _CryptoToken_cryptoPwdEncr},
 };
 
-static const struct field_t _CryptoH323Token[] = {	/* CHOICE */
+static const struct field _CryptoH323Token[] = {	/* CHOICE */
 	{FNAME("cryptoEPPwdHash") SEQ, 0, 3, 3, SKIP, 0,
 	 _CryptoH323Token_cryptoEPPwdHash},
 	{FNAME("cryptoGKPwdHash") SEQ, 0, 3, 3, SKIP, 0,
@@ -1297,17 +1297,17 @@ static const struct field_t _CryptoH323Token[] = {	/* CHOICE */
 	 _CryptoToken},
 };
 
-static const struct field_t _Progress_UUIE_cryptoTokens[] = {	/* SEQUENCE OF */
+static const struct field _Progress_UUIE_cryptoTokens[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 8, 8, SKIP | EXT, 0, _CryptoH323Token},
 };
 
-static const struct field_t _Progress_UUIE_fastStart[] = {	/* SEQUENCE OF */
+static const struct field _Progress_UUIE_fastStart[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 1, 3, 5, DECODE | OPEN | EXT,
 	 sizeof(OpenLogicalChannel), _OpenLogicalChannel}
 	,
 };
 
-static const struct field_t _Progress_UUIE[] = {	/* SEQUENCE */
+static const struct field _Progress_UUIE[] = {	/* SEQUENCE */
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("destinationInfo") SEQ, 6, 8, 10, SKIP | EXT, 0,
 	 _EndpointType},
@@ -1328,7 +1328,7 @@ static const struct field_t _Progress_UUIE[] = {	/* SEQUENCE */
 	{FNAME("fastConnectRefused") NUL, FIXD, 0, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _H323_UU_PDU_h323_message_body[] = {	/* CHOICE */
+static const struct field _H323_UU_PDU_h323_message_body[] = {	/* CHOICE */
 	{FNAME("setup") SEQ, 7, 13, 39, DECODE | EXT,
 	 offsetof(H323_UU_PDU_h323_message_body, setup), _Setup_UUIE},
 	{FNAME("callProceeding") SEQ, 1, 3, 12, DECODE | EXT,
@@ -1352,7 +1352,7 @@ static const struct field_t _H323_UU_PDU_h323_message_body[] = {	/* CHOICE */
 	{FNAME("notify") SEQ, 2, 4, 4, SKIP | EXT, 0, NULL},
 };
 
-static const struct field_t _RequestMessage[] = {	/* CHOICE */
+static const struct field _RequestMessage[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 1, 1, STOP | EXT, 0, NULL},
 	{FNAME("masterSlaveDetermination") SEQ, 0, 2, 2, STOP | EXT, 0, NULL},
 	{FNAME("terminalCapabilitySet") SEQ, 3, 5, 5, STOP | EXT, 0, NULL},
@@ -1372,7 +1372,7 @@ static const struct field_t _RequestMessage[] = {	/* CHOICE */
 	 NULL},
 };
 
-static const struct field_t _OpenLogicalChannelAck_reverseLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
+static const struct field _OpenLogicalChannelAck_reverseLogicalChannelParameters_multiplexParameters[] = {	/* CHOICE */
 	{FNAME("h222LogicalChannelParameters") SEQ, 3, 5, 5, SKIP | EXT, 0,
 	 _H222LogicalChannelParameters},
 	{FNAME("h2250LogicalChannelParameters") SEQ, 10, 11, 14, DECODE | EXT,
@@ -1381,7 +1381,7 @@ static const struct field_t _OpenLogicalChannelAck_reverseLogicalChannelParamete
 	  h2250LogicalChannelParameters), _H2250LogicalChannelParameters},
 };
 
-static const struct field_t _OpenLogicalChannelAck_reverseLogicalChannelParameters[] = {	/* SEQUENCE */
+static const struct field _OpenLogicalChannelAck_reverseLogicalChannelParameters[] = {	/* SEQUENCE */
 	{FNAME("reverseLogicalChannelNumber") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("portNumber") INT, WORD, 0, 0, SKIP | OPT, 0, NULL},
 	{FNAME("multiplexParameters") CHOICE, 0, 1, 2, DECODE | EXT | OPT,
@@ -1391,11 +1391,11 @@ static const struct field_t _OpenLogicalChannelAck_reverseLogicalChannelParamete
 	{FNAME("replacementFor") INT, WORD, 1, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _H2250LogicalChannelAckParameters_nonStandard[] = {	/* SEQUENCE OF */
+static const struct field _H2250LogicalChannelAckParameters_nonStandard[] = {	/* SEQUENCE OF */
 	{FNAME("item") SEQ, 0, 2, 2, SKIP, 0, _H245_NonStandardParameter},
 };
 
-static const struct field_t _H2250LogicalChannelAckParameters[] = {	/* SEQUENCE */
+static const struct field _H2250LogicalChannelAckParameters[] = {	/* SEQUENCE */
 	{FNAME("nonStandard") SEQOF, SEMI, 0, 0, SKIP | OPT, 0,
 	 _H2250LogicalChannelAckParameters_nonStandard},
 	{FNAME("sessionID") INT, 8, 1, 0, SKIP | OPT, 0, NULL},
@@ -1410,14 +1410,14 @@ static const struct field_t _H2250LogicalChannelAckParameters[] = {	/* SEQUENCE
 	{FNAME("portNumber") INT, WORD, 0, 0, SKIP | OPT, 0, NULL},
 };
 
-static const struct field_t _OpenLogicalChannelAck_forwardMultiplexAckParameters[] = {	/* CHOICE */
+static const struct field _OpenLogicalChannelAck_forwardMultiplexAckParameters[] = {	/* CHOICE */
 	{FNAME("h2250LogicalChannelAckParameters") SEQ, 5, 5, 7, DECODE | EXT,
 	 offsetof(OpenLogicalChannelAck_forwardMultiplexAckParameters,
 		  h2250LogicalChannelAckParameters),
 	 _H2250LogicalChannelAckParameters},
 };
 
-static const struct field_t _OpenLogicalChannelAck[] = {	/* SEQUENCE */
+static const struct field _OpenLogicalChannelAck[] = {	/* SEQUENCE */
 	{FNAME("forwardLogicalChannelNumber") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("reverseLogicalChannelParameters") SEQ, 2, 3, 4,
 	 DECODE | EXT | OPT, offsetof(OpenLogicalChannelAck,
@@ -1433,7 +1433,7 @@ static const struct field_t _OpenLogicalChannelAck[] = {	/* SEQUENCE */
 	{FNAME("encryptionSync") SEQ, 2, 4, 4, STOP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _ResponseMessage[] = {	/* CHOICE */
+static const struct field _ResponseMessage[] = {	/* CHOICE */
 	{FNAME("nonStandard") SEQ, 0, 1, 1, STOP | EXT, 0, NULL},
 	{FNAME("masterSlaveDeterminationAck") SEQ, 0, 1, 1, STOP | EXT, 0,
 	 NULL},
@@ -1469,7 +1469,7 @@ static const struct field_t _ResponseMessage[] = {	/* CHOICE */
 	{FNAME("logicalChannelRateReject") SEQ, 1, 4, 4, STOP | EXT, 0, NULL},
 };
 
-static const struct field_t _MultimediaSystemControlMessage[] = {	/* CHOICE */
+static const struct field _MultimediaSystemControlMessage[] = {	/* CHOICE */
 	{FNAME("request") CHOICE, 4, 11, 15, DECODE | EXT,
 	 offsetof(MultimediaSystemControlMessage, request), _RequestMessage},
 	{FNAME("response") CHOICE, 5, 19, 24, DECODE | EXT,
@@ -1479,14 +1479,14 @@ static const struct field_t _MultimediaSystemControlMessage[] = {	/* CHOICE */
 	{FNAME("indication") CHOICE, 4, 14, 23, STOP | EXT, 0, NULL},
 };
 
-static const struct field_t _H323_UU_PDU_h245Control[] = {	/* SEQUENCE OF */
+static const struct field _H323_UU_PDU_h245Control[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 2, 4, 4, DECODE | OPEN | EXT,
 	 sizeof(MultimediaSystemControlMessage),
 	 _MultimediaSystemControlMessage}
 	,
 };
 
-static const struct field_t _H323_UU_PDU[] = {	/* SEQUENCE */
+static const struct field _H323_UU_PDU[] = {	/* SEQUENCE */
 	{FNAME("h323-message-body") CHOICE, 3, 7, 13, DECODE | EXT,
 	 offsetof(H323_UU_PDU, h323_message_body),
 	 _H323_UU_PDU_h323_message_body},
@@ -1507,13 +1507,13 @@ static const struct field_t _H323_UU_PDU[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _H323_UserInformation[] = {	/* SEQUENCE */
+static const struct field _H323_UserInformation[] = {	/* SEQUENCE */
 	{FNAME("h323-uu-pdu") SEQ, 1, 2, 11, DECODE | EXT,
 	 offsetof(H323_UserInformation, h323_uu_pdu), _H323_UU_PDU},
 	{FNAME("user-data") SEQ, 0, 2, 2, STOP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _GatekeeperRequest[] = {	/* SEQUENCE */
+static const struct field _GatekeeperRequest[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
@@ -1537,7 +1537,7 @@ static const struct field_t _GatekeeperRequest[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _GatekeeperConfirm[] = {	/* SEQUENCE */
+static const struct field _GatekeeperConfirm[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
@@ -1557,23 +1557,23 @@ static const struct field_t _GatekeeperConfirm[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _RegistrationRequest_callSignalAddress[] = {	/* SEQUENCE OF */
+static const struct field _RegistrationRequest_callSignalAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 7, 7, DECODE | EXT,
 	 sizeof(TransportAddress), _TransportAddress}
 	,
 };
 
-static const struct field_t _RegistrationRequest_rasAddress[] = {	/* SEQUENCE OF */
+static const struct field _RegistrationRequest_rasAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 7, 7, DECODE | EXT,
 	 sizeof(TransportAddress), _TransportAddress}
 	,
 };
 
-static const struct field_t _RegistrationRequest_terminalAlias[] = {	/* SEQUENCE OF */
+static const struct field _RegistrationRequest_terminalAlias[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _RegistrationRequest[] = {	/* SEQUENCE */
+static const struct field _RegistrationRequest[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
@@ -1621,17 +1621,17 @@ static const struct field_t _RegistrationRequest[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _RegistrationConfirm_callSignalAddress[] = {	/* SEQUENCE OF */
+static const struct field _RegistrationConfirm_callSignalAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 7, 7, DECODE | EXT,
 	 sizeof(TransportAddress), _TransportAddress}
 	,
 };
 
-static const struct field_t _RegistrationConfirm_terminalAlias[] = {	/* SEQUENCE OF */
+static const struct field _RegistrationConfirm_terminalAlias[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _RegistrationConfirm[] = {	/* SEQUENCE */
+static const struct field _RegistrationConfirm[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("protocolIdentifier") OID, BYTE, 0, 0, SKIP, 0, NULL},
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
@@ -1667,13 +1667,13 @@ static const struct field_t _RegistrationConfirm[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _UnregistrationRequest_callSignalAddress[] = {	/* SEQUENCE OF */
+static const struct field _UnregistrationRequest_callSignalAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 7, 7, DECODE | EXT,
 	 sizeof(TransportAddress), _TransportAddress}
 	,
 };
 
-static const struct field_t _UnregistrationRequest[] = {	/* SEQUENCE */
+static const struct field _UnregistrationRequest[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("callSignalAddress") SEQOF, SEMI, 0, 10, DECODE,
 	 offsetof(UnregistrationRequest, callSignalAddress),
@@ -1694,24 +1694,24 @@ static const struct field_t _UnregistrationRequest[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _CallModel[] = {	/* CHOICE */
+static const struct field _CallModel[] = {	/* CHOICE */
 	{FNAME("direct") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 	{FNAME("gatekeeperRouted") NUL, FIXD, 0, 0, SKIP, 0, NULL},
 };
 
-static const struct field_t _AdmissionRequest_destinationInfo[] = {	/* SEQUENCE OF */
+static const struct field _AdmissionRequest_destinationInfo[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _AdmissionRequest_destExtraCallInfo[] = {	/* SEQUENCE OF */
+static const struct field _AdmissionRequest_destExtraCallInfo[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _AdmissionRequest_srcInfo[] = {	/* SEQUENCE OF */
+static const struct field _AdmissionRequest_srcInfo[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _AdmissionRequest[] = {	/* SEQUENCE */
+static const struct field _AdmissionRequest[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("callType") CHOICE, 2, 4, 4, SKIP | EXT, 0, _CallType},
 	{FNAME("callModel") CHOICE, 1, 2, 2, SKIP | EXT | OPT, 0, _CallModel},
@@ -1755,7 +1755,7 @@ static const struct field_t _AdmissionRequest[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _AdmissionConfirm[] = {	/* SEQUENCE */
+static const struct field _AdmissionConfirm[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("bandWidth") INT, CONS, 0, 0, SKIP, 0, NULL},
 	{FNAME("callModel") CHOICE, 1, 2, 2, SKIP | EXT, 0, _CallModel},
@@ -1790,11 +1790,11 @@ static const struct field_t _AdmissionConfirm[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _LocationRequest_destinationInfo[] = {	/* SEQUENCE OF */
+static const struct field _LocationRequest_destinationInfo[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 1, 2, 7, SKIP | EXT, 0, _AliasAddress},
 };
 
-static const struct field_t _LocationRequest[] = {	/* SEQUENCE */
+static const struct field _LocationRequest[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("endpointIdentifier") BMPSTR, 7, 1, 0, SKIP | OPT, 0, NULL},
 	{FNAME("destinationInfo") SEQOF, SEMI, 0, 0, SKIP, 0,
@@ -1818,7 +1818,7 @@ static const struct field_t _LocationRequest[] = {	/* SEQUENCE */
 	{FNAME("circuitInfo") SEQ, 3, 3, 3, STOP | EXT | OPT, 0, NULL},
 };
 
-static const struct field_t _LocationConfirm[] = {	/* SEQUENCE */
+static const struct field _LocationConfirm[] = {	/* SEQUENCE */
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
 	{FNAME("callSignalAddress") CHOICE, 3, 7, 7, DECODE | EXT,
 	 offsetof(LocationConfirm, callSignalAddress), _TransportAddress},
@@ -1844,13 +1844,13 @@ static const struct field_t _LocationConfirm[] = {	/* SEQUENCE */
 	{FNAME("serviceControl") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _InfoRequestResponse_callSignalAddress[] = {	/* SEQUENCE OF */
+static const struct field _InfoRequestResponse_callSignalAddress[] = {	/* SEQUENCE OF */
 	{FNAME("item") CHOICE, 3, 7, 7, DECODE | EXT,
 	 sizeof(TransportAddress), _TransportAddress}
 	,
 };
 
-static const struct field_t _InfoRequestResponse[] = {	/* SEQUENCE */
+static const struct field _InfoRequestResponse[] = {	/* SEQUENCE */
 	{FNAME("nonStandardData") SEQ, 0, 2, 2, SKIP | OPT, 0,
 	 _NonStandardParameter},
 	{FNAME("requestSeqNum") INT, WORD, 1, 0, SKIP, 0, NULL},
@@ -1873,7 +1873,7 @@ static const struct field_t _InfoRequestResponse[] = {	/* SEQUENCE */
 	{FNAME("genericData") SEQOF, SEMI, 0, 0, STOP | OPT, 0, NULL},
 };
 
-static const struct field_t _RasMessage[] = {	/* CHOICE */
+static const struct field _RasMessage[] = {	/* CHOICE */
 	{FNAME("gatekeeperRequest") SEQ, 4, 8, 18, DECODE | EXT,
 	 offsetof(RasMessage, gatekeeperRequest), _GatekeeperRequest},
 	{FNAME("gatekeeperConfirm") SEQ, 2, 5, 14, DECODE | EXT,
-- 
1.9.1
