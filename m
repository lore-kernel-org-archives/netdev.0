From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 7/8 v2] textsearch: convert kmalloc + memset to kzalloc
Date: Wed, 25 Jun 2008 03:25:07 -0700
Message-ID: <1214389507-21425-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:63569 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681AbYFYKZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 06:25:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so8130416rvb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 03:25:08 -0700 (PDT)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

convert kmalloc + memset to kzalloc for alloc_ts_config

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 include/linux/textsearch.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/textsearch.h b/include/linux/textsearch.h
index 6c34cf2..d9a85d6 100644
--- a/include/linux/textsearch.h
+++ b/include/linux/textsearch.h
@@ -162,11 +162,10 @@ static inline struct ts_config *alloc_ts_config(size_t payload,
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

