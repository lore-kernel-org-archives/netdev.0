From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 2/2] Bugfix: xt_hashlimit does a wrong SEQ_SKIP.
Date: Tue, 26 May 2009 15:18:57 +0200
Message-ID: <20090526131857.7377.6946.stgit@localhost>
References: <20090526131852.7377.68330.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"Patrick McHardy" <kaber@trash.net>,
	"Jonathan Corbet" <corbet@lwn.net>,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090526131852.7377.68330.stgit@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Inside net/netfilter/xt_hashlimit.c)
The function dl_seq_show() returns 1 (equal to SEQ_SKIP) in case
a seq_printf() call return -1.  It should return -1.

This SEQ_SKIP behavior brakes processing the proc file e.g. via a
pipe or just through less.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/netfilter/xt_hashlimit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index a5b5369..219dcdb 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -926,7 +926,7 @@ static int dl_seq_show(struct seq_file *s, void *v)
 	if (!hlist_empty(&htable->hash[*bucket])) {
 		hlist_for_each_entry(ent, pos, &htable->hash[*bucket], node)
 			if (dl_seq_real_show(ent, htable->family, s))
-				return 1;
+				return -1;
 	}
 	return 0;
 }

