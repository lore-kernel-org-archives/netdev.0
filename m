From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/6] net: adjust array index
Date: Thu, 28 Jul 2011 14:46:01 +0200
Message-ID: <1311857165-14780-2-git-send-email-julia@diku.dk>
References: <1311857165-14780-1-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311857165-14780-1-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Convert array index from the loop bound to the loop index.

A simplified version of the semantic patch that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e1,e2,ar;
@@

for(e1 = 0; e1 < e2; e1++) { <...
  ar[
- e2
+ e1
  ]
  ...> }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
Not tested.

 net/ipv4/igmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1718,7 +1718,7 @@ static int ip_mc_add_src(struct in_devic
 
 		pmc->sfcount[sfmode]--;
 		for (j=0; j<i; j++)
-			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[i]);
+			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
 #ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
