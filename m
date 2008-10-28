From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/6] net: replace all current users of NIP6_SEQFMT with %#p6
Date: Tue, 28 Oct 2008 12:53:36 -0700
Message-ID: <1225223616.11483.40.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:47380 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbYJ1Txk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 15:53:40 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2778520wfd.4
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 12:53:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The define in kernel.h can be done away with at a later time.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 fs/cifs/cifs_spnego.c    |    3 +--
 net/ipv6/addrconf.c      |    5 ++---
 net/ipv6/anycast.c       |    6 ++----
 net/ipv6/ip6_flowlabel.c |    4 ++--
 net/ipv6/mcast.c         |   10 +++++-----
 net/ipv6/route.c         |    9 +++------
 net/sunrpc/xprtsock.c    |    7 +++----
 7 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/fs/cifs/cifs_spnego.c b/fs/cifs/cifs_spnego.c
index fcee929..ae4be82 100644
--- a/fs/cifs/cifs_spnego.c
+++ b/fs/cifs/cifs_spnego.c
@@ -124,8 +124,7 @@ cifs_get_spnego_key(struct cifsSesInfo *sesInfo)
 		sprintf(dp, "ip4=" NIPQUAD_FMT,
 			NIPQUAD(server->addr.sockAddr.sin_addr));
 	else if (server->addr.sockAddr.sin_family == AF_INET6)
-		sprintf(dp, "ip6=" NIP6_SEQFMT,
-			NIP6(server->addr.sockAddr6.sin6_addr));
+		sprintf(dp, "ip6=%#p6", &server->addr.sockAddr6.sin6_addr);
 	else
 		goto out;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index eea9542..113c4d9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2986,9 +2986,8 @@ static void if6_seq_stop(struct seq_file *seq, void *v)
 static int if6_seq_show(struct seq_file *seq, void *v)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
-	seq_printf(seq,
-		   NIP6_SEQFMT " %02x %02x %02x %02x %8s\n",
-		   NIP6(ifp->addr),
+	seq_printf(seq, "%#p6 %02x %02x %02x %02x %8s\n",
+		   &ifp->addr,
 		   ifp->idev->dev->ifindex,
 		   ifp->prefix_len,
 		   ifp->scope,
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 8336cd8..ae494e3 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -512,11 +512,9 @@ static int ac6_seq_show(struct seq_file *seq, void *v)
 	struct ifacaddr6 *im = (struct ifacaddr6 *)v;
 	struct ac6_iter_state *state = ac6_seq_private(seq);
 
-	seq_printf(seq,
-		   "%-4d %-15s " NIP6_SEQFMT " %5d\n",
+	seq_printf(seq, "%-4d %-15s %#p6 %5d\n",
 		   state->dev->ifindex, state->dev->name,
-		   NIP6(im->aca_addr),
-		   im->aca_users);
+		   &im->aca_addr, im->aca_users);
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 37a4e77..d571023 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -696,14 +696,14 @@ static int ip6fl_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
-			   "%05X %-1d %-6d %-6d %-6ld %-8ld " NIP6_SEQFMT " %-4d\n",
+			   "%05X %-1d %-6d %-6d %-6ld %-8ld %#p6 %-4d\n",
 			   (unsigned)ntohl(fl->label),
 			   fl->share,
 			   (unsigned)fl->owner,
 			   atomic_read(&fl->users),
 			   fl->linger/HZ,
 			   (long)(fl->expires - jiffies)/HZ,
-			   NIP6(fl->dst),
+			   &fl->dst,
 			   fl->opt ? fl->opt->opt_nflen : 0);
 	}
 	return 0;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d7b3c6d..4416cdc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2430,9 +2430,9 @@ static int igmp6_mc_seq_show(struct seq_file *seq, void *v)
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
 
 	seq_printf(seq,
-		   "%-4d %-15s " NIP6_SEQFMT " %5d %08X %ld\n",
+		   "%-4d %-15s %#p6 %5d %08X %ld\n",
 		   state->dev->ifindex, state->dev->name,
-		   NIP6(im->mca_addr),
+		   &im->mca_addr,
 		   im->mca_users, im->mca_flags,
 		   (im->mca_flags&MAF_TIMER_RUNNING) ?
 		   jiffies_to_clock_t(im->mca_timer.expires-jiffies) : 0);
@@ -2591,10 +2591,10 @@ static int igmp6_mcf_seq_show(struct seq_file *seq, void *v)
 			   "Source Address", "INC", "EXC");
 	} else {
 		seq_printf(seq,
-			   "%3d %6.6s " NIP6_SEQFMT " " NIP6_SEQFMT " %6lu %6lu\n",
+			   "%3d %6.6s %#p6 %#p6 %6lu %6lu\n",
 			   state->dev->ifindex, state->dev->name,
-			   NIP6(state->im->mca_addr),
-			   NIP6(psf->sf_addr),
+			   &state->im->mca_addr,
+			   &psf->sf_addr,
 			   psf->sf_count[MCAST_INCLUDE],
 			   psf->sf_count[MCAST_EXCLUDE]);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 89dc699..720bfed 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2408,19 +2408,16 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
 	struct seq_file *m = p_arg;
 
-	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_dst.addr),
-		   rt->rt6i_dst.plen);
+	seq_printf(m, "%#p6 %02x ", &rt->rt6i_dst.addr, rt->rt6i_dst.plen);
 
 #ifdef CONFIG_IPV6_SUBTREES
-	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_src.addr),
-		   rt->rt6i_src.plen);
+	seq_printf(m, "%#p6 %02x ", &rt->rt6i_src.addr, rt->rt6i_src.plen);
 #else
 	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 
 	if (rt->rt6i_nexthop) {
-		seq_printf(m, NIP6_SEQFMT,
-			   NIP6(*((struct in6_addr *)rt->rt6i_nexthop->primary_key)));
+		seq_printf(m, "%#p6", rt->rt6i_nexthop->primary_key);
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9a288d5..59155ae 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -365,10 +365,9 @@ static void xs_format_ipv6_peer_addresses(struct rpc_xprt *xprt,
 	xprt->address_strings[RPC_DISPLAY_ALL] = buf;
 
 	buf = kzalloc(36, GFP_KERNEL);
-	if (buf) {
-		snprintf(buf, 36, NIP6_SEQFMT,
-				NIP6(addr->sin6_addr));
-	}
+	if (buf)
+		snprintf(buf, 36, "%#p6", &addr->sin6_addr);
+
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = buf;
 
 	buf = kzalloc(8, GFP_KERNEL);
-- 
1.6.0.3.729.g6ea410


