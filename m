From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/9] ethtool: add CRC32 as an RSS hash function
Date: Wed,  8 Mar 2017 08:57:00 -0800
Message-ID: <20170308165708.96087-2-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34451 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753058AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pf0-f173.google.com with SMTP id v190so16982913pfb.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:09 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CRC32 engines are usually easily available in hardware and generate
OK spread for RSS hash.  Add CRC32 RSS hash function to ethtool API.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/ethtool.h | 2 ++
 net/core/ethtool.c      | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6d8176..83cc9863444b 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -60,6 +60,7 @@ enum ethtool_phys_id_state {
 enum {
 	ETH_RSS_HASH_TOP_BIT, /* Configurable RSS hash function - Toeplitz */
 	ETH_RSS_HASH_XOR_BIT, /* Configurable RSS hash function - Xor */
+	ETH_RSS_HASH_CRC32_BIT, /* Configurable RSS hash function - Crc32 */
 
 	/*
 	 * Add your fresh new hash function bits above and remember to update
@@ -73,6 +74,7 @@ enum {
 
 #define ETH_RSS_HASH_TOP	__ETH_RSS_HASH(TOP)
 #define ETH_RSS_HASH_XOR	__ETH_RSS_HASH(XOR)
+#define ETH_RSS_HASH_CRC32	__ETH_RSS_HASH(CRC32)
 
 #define ETH_RSS_HASH_UNKNOWN	0
 #define ETH_RSS_HASH_NO_CHANGE	0
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index aecb2c7241b6..905a88ad28e0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -109,6 +109,7 @@ static const char
 rss_hash_func_strings[ETH_RSS_HASH_FUNCS_COUNT][ETH_GSTRING_LEN] = {
 	[ETH_RSS_HASH_TOP_BIT] =	"toeplitz",
 	[ETH_RSS_HASH_XOR_BIT] =	"xor",
+	[ETH_RSS_HASH_CRC32_BIT] =	"crc32",
 };
 
 static const char
-- 
2.11.0
