From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 7/8] textsearch: convert kmalloc + memset to kzalloc
Date: Sat, 21 Jun 2008 00:54:21 -0700
Message-ID: <1214034861-1398-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert kmalloc + memset to kzalloc for alloc_ts_config

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/textsearch.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/textsearch.h b/include/linux/textsearch.h
index b6897f3..4341406 100644
--- a/include/linux/textsearch.h
+++ b/include/linux/textsearch.h
@@ -164,11 +164,10 @@ static inline struct ts_config *alloc_ts_config(size_t payload,
 {
 	struct ts_config *conf;
 
-	conf = kmalloc(TS_PRIV_ALIGN(sizeof(*conf)) + payload, gfp_mask);
+	conf = kzalloc(TS_PRIV_ALIGN(sizeof(*conf)) + payload, gfp_mask);
 	if (conf == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	memset(conf, 0, TS_PRIV_ALIGN(sizeof(*conf)) + payload);
 	return conf;
 }
 
-- 
1.5.4.3

