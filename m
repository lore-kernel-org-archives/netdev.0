From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 6349] New: iptables DNAT returns unknown
 error 4294967295
Date: Sat, 08 Apr 2006 13:51:21 +0200
Message-ID: <4437A3B9.8000000@trash.net>
References: <20060407142331.26e6b653.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020808050407020606000804"
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: dmb@pochta.ru
In-Reply-To: <20060407142331.26e6b653.akpm@osdl.org>
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
--------------020808050407020606000804
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Fri, 7 Apr 2006 06:12:07 -0700
> From: bugme-daemon@bugzilla.kernel.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 6349] New: iptables DNAT returns unknown error 4294967295
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=6349
> 
>            Summary: iptables DNAT returns unknown error 4294967295
>     Kernel Version: 2.6.17-rc1
>             Status: NEW
>           Severity: blocking
>              Owner: laforge@gnumonks.org
>          Submitter: dmb@pochta.ru
> 
> 
> Problem Description:
> When I try to add the rule with target DNAT to the OUTPUT chain I get the error
> message:
> [root@dbagrii:~]# iptables -t nat -A OUTPUT -p tcp -d 192.168.1.1 --dport 119 -j
> DNAT --to-destination 192.168.1.10:8119
> iptables: Unknown error 4294967295
> 
> No rule is added, and the kernel says the message to the syslog:
> Apr  7 15:20:05 dbagrii kernel: ip_tables: DNAT target: bad hook_mask 8
> 
> This error appears with iptables tool version 1.3.3 and 1.3.5 i tried to use.
> 
> Steps to reproduce:
> Run the iptables tool with this arguments:
> $ iptables -t nat -A OUTPUT -p tcp -d 192.168.1.1 --dport 119 -j DNAT
> --to-destination 192.168.1.10:8119

Please try if this patch helps.


--------------020808050407020606000804
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: Fix DNAT in LOCAL_OUT

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0fc7ff57191de5c09afe7db3932009963bba44d6
tree 02bc033088605bfd51fa4ea7ceb57d0aae1db65e
parent 8cc24d7ca2ffc6d9d70e1d94dc8dffbdf677e58f
author Patrick McHardy <kaber@trash.net> Sat, 08 Apr 2006 13:52:18 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 08 Apr 2006 13:52:18 +0200

 net/ipv4/netfilter/ip_nat_rule.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_nat_rule.c b/net/ipv4/netfilter/ip_nat_rule.c
index efba8c4..250b8ed 100644
--- a/net/ipv4/netfilter/ip_nat_rule.c
+++ b/net/ipv4/netfilter/ip_nat_rule.c
@@ -279,7 +279,7 @@ static struct ipt_target ipt_dnat_reg = 
 	.target		= ipt_dnat_target,
 	.targetsize	= sizeof(struct ip_nat_multi_range_compat),
 	.table		= "nat",
-	.hooks		= 1 << NF_IP_PRE_ROUTING,
+	.hooks		= 1 << NF_IP_PRE_ROUTING || 1 << NF_IP_LOCAL_OUT,
 	.checkentry	= ipt_dnat_checkentry,
 };
 

--------------020808050407020606000804--
