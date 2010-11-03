From: kaber@trash.net
Subject: [PATCH 4/5] ipv4: netfilter: arp_tables: fix information leak to userland
Date: Wed,  3 Nov 2010 23:12:51 +0100
Message-ID: <1288822372-21245-5-git-send-email-kaber@trash.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288822372-21245-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segooon@gmail.com>

Structure arpt_getinfo is copied to userland with the field "name"
that has the last elements unitialized.  It leads to leaking of
contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/arp_tables.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 3cad259..3fac340 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -927,6 +927,7 @@ static int get_info(struct net *net, void __user *user,
 			private = &tmp;
 		}
 #endif
+		memset(&info, 0, sizeof(info));
 		info.valid_hooks = t->valid_hooks;
 		memcpy(info.hook_entry, private->hook_entry,
 		       sizeof(info.hook_entry));
-- 
1.7.1

