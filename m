From: kaber@trash.net
Subject: [PATCH 1/4] netfilter: xt_recent: fix regression in rules using a zero hit_count
Date: Thu, 25 Mar 2010 18:54:43 +0100
Message-ID: <1269539686-3885-2-git-send-email-kaber@trash.net>
References: <1269539686-3885-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1269539686-3885-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Commit 8ccb92ad (netfilter: xt_recent: fix false match) fixed supposedly
false matches in rules using a zero hit_count. As it turns out there is
nothing false about these matches and people are actually using entries
with a hit_count of zero to make rules dependant on addresses inserted
manually through /proc.

Since this slipped past the eyes of three reviewers, instead of
reverting the commit in question, this patch explicitly checks
for a hit_count of zero to make the intentions more clear.

Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Tested-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Cc: stable@kernel.org
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_recent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 7073dbb..971d172 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -267,7 +267,7 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		for (i = 0; i < e->nstamps; i++) {
 			if (info->seconds && time_after(time, e->stamps[i]))
 				continue;
-			if (info->hit_count && ++hits >= info->hit_count) {
+			if (!info->hit_count || ++hits >= info->hit_count) {
 				ret = !ret;
 				break;
 			}
-- 
1.6.5.7

