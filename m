From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec-next] pfkey: fix SADB_X_EXT_FILTER length check
Date: Thu, 20 Feb 2014 14:52:41 +0100
Message-ID: <1392904361-11127-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20140220100735.GA25752@elgon.mountain>
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com,
	kbuild-all@01.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39769 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbaBTNxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 08:53:06 -0500
In-Reply-To: <20140220100735.GA25752@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes commit d3623099d350 ("ipsec: add support of limited SA dump").

sadb_ext_min_len array should be updated with the new type (SADB_X_EXT_FILTER).

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/key/af_key.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f0879c19f452..a50d979b5926 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -365,6 +365,7 @@ static const u8 sadb_ext_min_len[] = {
 	[SADB_X_EXT_NAT_T_OA]		= (u8) sizeof(struct sadb_address),
 	[SADB_X_EXT_SEC_CTX]		= (u8) sizeof(struct sadb_x_sec_ctx),
 	[SADB_X_EXT_KMADDRESS]		= (u8) sizeof(struct sadb_x_kmaddress),
+	[SADB_X_EXT_FILTER]		= (u8) sizeof(struct sadb_x_filter),
 };
 
 /* Verify sadb_address_{len,prefixlen} against sa_family.  */
-- 
1.8.5.4
