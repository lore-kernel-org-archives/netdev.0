From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/4] net: replace %#p6 format specifier with %pi6
Date: Wed, 29 Oct 2008 11:35:40 -0700
Message-ID: <1225305340.5688.37.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f12.google.com ([209.85.217.12]:53959 "EHLO
	mail-gx0-f12.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbYJ2TMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 15:12:25 -0400
Received: by gxk5 with SMTP id 5so94980gxk.13
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 12:12:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc warns when using the # modifier with the %p format specifier,
so we can't use this to omit the colons when needed, introduces
%pi6 instead.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 fs/cifs/cifs_spnego.c    |    2 +-
 net/ipv6/addrconf.c      |    2 +-
 net/ipv6/anycast.c       |    2 +-
 net/ipv6/ip6_flowlabel.c |    2 +-
 net/ipv6/mcast.c         |    4 ++--
 net/ipv6/route.c         |    6 +++---
 net/sunrpc/xprtsock.c    |    2 +-
 7 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
index ae4be82..0e186cd 100644
--- a/fs/cifs/cifs_spnego.c
+++ b/fs/cifs/cifs_spnego.c
@@ -124,7 +124,7 @@ cifs_get_spnego_key(struct cifsSesInfo *sesInfo)
 		sprintf(dp, "ip4=" NIPQUAD_FMT,
 			NIPQUAD(server->addr.sockAddr.sin_addr));
 	else if (server->addr.sockAddr.sin_family == AF_INET6)
-		sprintf(dp, "ip6=%#p6", &server->addr.sockAddr6.sin6_addr);
+		sprintf(dp, "ip6=%pi6", &server->addr.sockAddr6.sin6_addr);
 	else
 		goto out;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 113c4d9..ff7ae05 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2986,7 +2986,7 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq, "%#p6 %02x %02x %02x %02x %8s\n",
+	seq_printf(seq, "%pi6 %02x %02x %02x %02x %8s\n",
 		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index ae494e3..1ae58be 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -512,7 +512,7 @@ static int ac6_seq_show(struct seq_file *seq, void *v)
 	struct ifacaddr6 *im = (struct ifacaddr6 *)v;
 	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-	seq_printf(seq, "%-4d %-15s %#p6 %5d\n",
+	seq_printf(seq, "%-4d %-15s %pi6 %5d\n",
 		   state->dev->ifindex, state->dev->name,
 		   &im->aca_addr, im->aca_users);
 	return 0;
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index d571023..7927a84 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -696,7 +696,7 @@ static int ip6fl_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
-			   "%05X %-1d %-6d %-6d %-6ld %-8ld %#p6 %-4d\n",
+			   "%05X %-1d %-6d %-6d %-6ld %-8ld %pi6 %-4d\n",
 			   (unsigned)ntohl(fl->label),
 			   fl->share,
 			   (unsigned)fl->owner,
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 4416cdc..a76199e 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2430,7 +2430,7 @@ static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
 	seq_printf(seq,
-		   "%-4d %-15s %#p6 %5d %08X %ld\n",
+		   "%-4d %-15s %pi6 %5d %08X %ld\n",
 		   state->dev->ifindex, state->dev->name,
 		   &im->mca_addr,
 		   im->mca_users, im->mca_flags,
@@ -2591,7 +2591,7 @@ static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
 			   "Source Address", "INC", "EXC");
 	} else {
 		seq_printf(seq,
-			   "%3d %6.6s %#p6 %#p6 %6lu %6lu\n",
+			   "%3d %6.6s %pi6 %pi6 %6lu %6lu\n",
 			   state->dev->ifindex, state->dev->name,
 			   &state->im->mca_addr,
 			   &psf->sf_addr,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 720bfed..d69fa46 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2408,16 +2408,16 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct seq_file *m = p_arg;
 
-	seq_printf(m, "%#p6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
+	seq_printf(m, "%pi6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
 
 #ifdef CONFIG_IPV6_SUBTREES
-	seq_printf(m, "%#p6 %02x ", &rt->rt6i_src.addr, rt->rt6i_src.plen);
+	seq_printf(m, "%pi6 %02x ", &rt->rt6i_src.addr, rt->rt6i_src.plen);
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 
 	if (rt->rt6i_nexthop) {
-		seq_printf(m, "%#p6", rt->rt6i_nexthop->primary_key);
+		seq_printf(m, "%pi6", rt->rt6i_nexthop->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3498522..3c9aff5 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -365,7 +365,7 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 
 	buf = kzalloc(36, GFP_KERNEL);
 	if (buf)
-		snprintf(buf, 36, "%#p6", &addr->sin6_addr);
+		snprintf(buf, 36, "%pi6", &addr->sin6_addr);
 
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
 
-- 
1.6.0.3.756.gb776d


