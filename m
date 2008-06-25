From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 2/8 v2] textsearch: fix Boyer-Moore text search bug
Date: Wed, 25 Jun 2008 03:24:55 -0700
Message-ID: <1214389495-21325-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:63005 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbYFYKY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 06:24:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so8130417rvb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 03:24:56 -0700 (PDT)
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current logic has a bug which cannot find matching pattern, if the
pattern is matched from the first character of target string.
for example:
	pattern=abc, string=abcdefg
	pattern=a,   string=abcdefg
Searching algorithm should return 0 for those things.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 lib/ts_bm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/ts_bm.c b/lib/ts_bm.c
index d90822c..4a7fce7 100644
--- a/lib/ts_bm.c
+++ b/lib/ts_bm.c
@@ -63,7 +63,7 @@ static unsigned int bm_find(struct ts_config *conf, struct ts_state *state)
 	struct ts_bm *bm = ts_config_priv(conf);
 	unsigned int i, text_len, consumed = state->offset;
 	const u8 *text;
-	int shift = bm->patlen, bs;
+	int shift = bm->patlen - 1, bs;
 
 	for (;;) {
 		text_len = conf->get_next_block(consumed, &text, conf, state);
-- 
1.5.4.3

