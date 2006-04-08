From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 6349] New: iptables DNAT returns unknown
 error 4294967295
Date: Sat, 08 Apr 2006 13:58:10 +0200
Message-ID: <4437A552.902@trash.net>
References: <20060407142331.26e6b653.akpm@osdl.org>
	<4437A3B9.8000000@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040609080205000300020202"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: dmb@pochta.ru
In-Reply-To: <4437A3B9.8000000@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040609080205000300020202
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Please try if this patch helps.
> 
> +	.hooks		= 1 << NF_IP_PRE_ROUTING || 1 << NF_IP_LOCAL_OUT,

I shouldn't send patches before getting out of bed .. :)

Please try this one instead.


--------------040609080205000300020202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix DNAT in LOCAL_OUT

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2ceefa038e908d5da21aefedae02da4eab1b2787
tree 417f03eca3b97b16a78321ace1556e57f5c60351
parent 8cc24d7ca2ffc6d9d70e1d94dc8dffbdf677e58f
author Patrick McHardy <kaber@trash.net> Sat, 08 Apr 2006 13:59:53 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 08 Apr 2006 13:59:53 +0200

 net/ipv4/netfilter/ip_nat_rule.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_rule.c b/net/ipv4/netfilter/ip_nat_rule.c
index efba8c4..1aba926 100644
--- a/net/ipv4/netfilter/ip_nat_rule.c
+++ b/net/ipv4/netfilter/ip_nat_rule.c
@@ -279,7 +279,7 @@ static struct ipt_target ipt_dnat_reg = 
 	.target		= ipt_dnat_target,
 	.targetsize	= sizeof(struct ip_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= 1 << NF_IP_PRE_ROUTING,
+	.hooks		= (1 << NF_IP_PRE_ROUTING) | (1 << NF_IP_LOCAL_OUT),
 	.checkentry	= ipt_dnat_checkentry,
 };
 

--------------040609080205000300020202--
