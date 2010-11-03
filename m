From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 5/5] ipv4: netfilter: ip_tables: fix information leak to
 userland
Date: Wed, 3 Nov 2010 23:55:58 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011032355020.31351@obet.zrqbmnf.qr>
References: <1288822372-21245-1-git-send-email-kaber@trash.net> <1288822372-21245-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288822372-21245-6-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2010-11-03 23:12, kaber@trash.net wrote:

>From: Vasiliy Kulikov <segooon@gmail.com>
>
>Structure ipt_getinfo is copied to userland with the field "name"
>that has the last elements unitialized.  It leads to leaking of
>contents of kernel stack memory.
>
>Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
>Signed-off-by: Patrick McHardy <kaber@trash.net>
>---
> net/ipv4/netfilter/ip_tables.c |    1 +


But then we would also need this:


--------8<-------------
parent 93aa45607748d2ffa73f41a435dced6a2fd90cb5 (v2.6.36-rc3-1020-g93aa456)
commit 8aff3f67fa47f7d3211aea8bbef999554d6f65e5
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Nov 3 23:55:18 2010 +0100

netfilter: ip6_tables: fix information leak to userspace

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv6/netfilter/ip6_tables.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c683e9e..d13f893 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1137,6 +1137,7 @@ static int get_info(struct net *net, void __user *user,
 			private = &tmp;
 		}
 #endif
+		memset(&info, 0, sizeof(info));
 		info.valid_hooks = t->valid_hooks;
 		memcpy(info.hook_entry, private->hook_entry,
 		       sizeof(info.hook_entry));
-- 
# Created with git-export-patch
