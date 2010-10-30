From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] ipv4: netfilter: ip_tables: fix information leak to userland
Date: Sat, 30 Oct 2010 18:26:50 +0400
Message-ID: <1288448810-6628-1-git-send-email-segooon@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Structure ipt_getinfo is copied to userland with the field "name"
that has the last elements unitialized.  It leads to leaking of
contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 net/ipv4/netfilter/ip_tables.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d31b007..a846d63 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1124,6 +1124,7 @@ static int get_info(struct net *net, void __user *user,
 			private = &tmp;
 		}
 #endif
+		memset(&info, 0, sizeof(info));
 		info.valid_hooks = t->valid_hooks;
 		memcpy(info.hook_entry, private->hook_entry,
 		       sizeof(info.hook_entry));
-- 
1.7.0.4
