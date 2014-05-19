From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/13] [NETFILTER]: arp_tables: make return of 0 explicit
Date: Mon, 19 May 2014 06:31:08 +0200
Message-ID: <1400473875-22228-7-git-send-email-Julia.Lawall@lip6.fr>
References: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Delete unnecessary local variable whose value is always 0 and that hides
the fact that the result is always 0.

A simplified version of the semantic patch that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
local idexpression ret;
expression e;
position p;
@@

-ret = 0;
... when != ret = e
return 
- ret
+ 0
  ;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/ipv4/netfilter/arp_tables.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f95b6f9..89f6737 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1289,9 +1289,8 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 	struct xt_target *target;
 	struct arpt_entry *de;
 	unsigned int origsize;
-	int ret, h;
+	int h;
 
-	ret = 0;
 	origsize = *size;
 	de = (struct arpt_entry *)*dstptr;
 	memcpy(de, e, sizeof(struct arpt_entry));
@@ -1312,7 +1311,7 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 		if ((unsigned char *)de - base < newinfo->underflow[h])
 			newinfo->underflow[h] -= origsize - *size;
 	}
-	return ret;
+	return 0;
 }
 
 static int translate_compat_table(const char *name,
