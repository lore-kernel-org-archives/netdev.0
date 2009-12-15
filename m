From: Patrick McHardy <kaber@trash.net>
Subject: ipvs 05/05: zero usvc and udest
Date: Tue, 15 Dec 2009 17:14:33 +0100 (MET)
Message-ID: <20091215161432.4146.56195.sendpatchset@x2.localnet>
References: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091215161426.4146.55284.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 258c889362aa95d0ab534b38ce8c15d3009705b1
Author: Simon Horman <horms@verge.net.au>
Date:   Tue Dec 15 17:01:25 2009 +0100

    ipvs: zero usvc and udest
    
    Make sure that any otherwise uninitialised fields of usvc are zero.
    
    This has been obvserved to cause a problem whereby the port of
    fwmark services may end up as a non-zero value which causes
    scheduling of a destination server to fail for persisitent services.
    
    As observed by Deon van der Merwe <dvdm@truteq.co.za>.
    This fix suggested by Julian Anastasov <ja@ssi.bg>.
    
    For good measure also zero udest.
    
    Cc: Deon van der Merwe <dvdm@truteq.co.za>
    Acked-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Cc: stable@kernel.org
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e55a686..6bde12d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2714,6 +2714,8 @@ static int ip_vs_genl_parse_service(struct ip_vs_service_user_kern *usvc,
 	if (!(nla_af && (nla_fwmark || (nla_port && nla_protocol && nla_addr))))
 		return -EINVAL;
 
+	memset(usvc, 0, sizeof(*usvc));
+
 	usvc->af = nla_get_u16(nla_af);
 #ifdef CONFIG_IP_VS_IPV6
 	if (usvc->af != AF_INET && usvc->af != AF_INET6)
@@ -2901,6 +2903,8 @@ static int ip_vs_genl_parse_dest(struct ip_vs_dest_user_kern *udest,
 	if (!(nla_addr && nla_port))
 		return -EINVAL;
 
+	memset(udest, 0, sizeof(*udest));
+
 	nla_memcpy(&udest->addr, nla_addr, sizeof(udest->addr));
 	udest->port = nla_get_u16(nla_port);
 
