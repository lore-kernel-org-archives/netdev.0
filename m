From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 5/5] net/dns_resolver/dns_key.c: use kstrtoul, etc
Date: Sun,  6 Nov 2011 14:26:50 +0100
Message-ID: <1320586010-21931-6-git-send-email-julia@diku.dk>
References: <1320586010-21931-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320586010-21931-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kstrtoul, etc instead of the now deprecated strict_strtoul, etc.

A semantic patch rule for the kstrtoul case is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression a,b;
{int,long} *c;
@@

-strict_strtoul
+kstrtoul
 (a,b,c)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/dns_resolver/dns_key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -118,7 +118,7 @@ dns_resolver_instantiate(struct key *key
 				if (opt_vlen <= 0)
 					goto bad_option_value;
 
-				ret = strict_strtoul(eq, 10, &derrno);
+				ret = kstrtoul(eq, 10, &derrno);
 				if (ret < 0)
 					goto bad_option_value;
 
