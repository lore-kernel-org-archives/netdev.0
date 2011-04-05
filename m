From: kaber@trash.net
Subject: [PATCH 3/8] netfilter: h323: bug in parsing of ASN1 SEQOF field
Date: Tue,  5 Apr 2011 15:04:14 +0200
Message-ID: <1302008659-21141-4-git-send-email-kaber@trash.net>
References: <1302008659-21141-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1302008659-21141-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Sterba <dsterba@suse.cz>

Static analyzer of clang found a dead store which appears to be a bug in
reading count of items in SEQOF field, only the lower byte of word is
stored. This may lead to corrupted read and communication shutdown.

The bug has been in the module since it's first inclusion into linux
kernel.

[Patrick: the bug is real, but without practical consequence since the
 largest amount of sequence-of members we parse is 30.]

Signed-off-by: David Sterba <dsterba@suse.cz>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_h323_asn1.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index 8678823..bcd5ed6 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -631,7 +631,7 @@ static int decode_seqof(bitstr_t *bs, const struct field_t *f,
 		CHECK_BOUND(bs, 2);
 		count = *bs->cur++;
 		count <<= 8;
-		count = *bs->cur++;
+		count += *bs->cur++;
 		break;
 	case SEMI:
 		BYTE_ALIGN(bs);
-- 
1.7.2.3

