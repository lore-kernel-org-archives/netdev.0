From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 5/8 v2] textsearch: fix finite state machine textsearch for handling case insensitive searching
Date: Wed, 25 Jun 2008 03:25:03 -0700
Message-ID: <1214389503-21385-1-git-send-email-joonwpark81@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Joonwoo Park <joonwpark81@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For fsm text search, handle case insensitive parameter as -EINVAL.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 lib/ts_fsm.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/ts_fsm.c b/lib/ts_fsm.c
index af575b6..5696a35 100644
--- a/lib/ts_fsm.c
+++ b/lib/ts_fsm.c
@@ -257,7 +257,7 @@ found_match:
 }
 
 static struct ts_config *fsm_init(const void *pattern, unsigned int len,
-				     gfp_t gfp_mask)
+				    gfp_t gfp_mask, int flags)
 {
 	int i, err = -EINVAL;
 	struct ts_config *conf;
@@ -269,6 +269,9 @@ static struct ts_config *fsm_init(const void *pattern, unsigned int len,
 	if (len  % sizeof(struct ts_fsm_token) || ntokens < 1)
 		goto errout;
 
+	if (flags & TS_IGNORECASE)
+		goto errout;
+
 	for (i = 0; i < ntokens; i++) {
 		struct ts_fsm_token *t = &tokens[i];
 
@@ -284,6 +287,7 @@ static struct ts_config *fsm_init(const void *pattern, unsigned int len,
 	if (IS_ERR(conf))
 		return conf;
 
+	conf->flags = flags;
 	fsm = ts_config_priv(conf);
 	fsm->ntokens = ntokens;
 	memcpy(fsm->tokens, pattern, len);
-- 
1.5.4.3

