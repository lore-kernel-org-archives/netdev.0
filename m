From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/13] bridge: netfilter: Convert
	compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:48 -0700
Message-ID: <5a91d328db3393320170723cdfc9395ad59182c6.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/netfilter/ebt_stp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 5b33a2e..071d872 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -164,8 +164,8 @@ static int ebt_stp_mt_check(const struct xt_mtchk_param *par)
 	    !(info->bitmask & EBT_STP_MASK))
 		return -EINVAL;
 	/* Make sure the match only receives stp frames */
-	if (compare_ether_addr(e->destmac, bridge_ula) ||
-	    compare_ether_addr(e->destmsk, msk) || !(e->bitmask & EBT_DESTMAC))
+	if (!ether_addr_equal(e->destmac, bridge_ula) ||
+	    !ether_addr_equal(e->destmsk, msk) || !(e->bitmask & EBT_DESTMAC))
 		return -EINVAL;
 
 	return 0;
-- 
1.7.8.111.gad25c.dirty
