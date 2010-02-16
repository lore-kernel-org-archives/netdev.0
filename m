From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/62: xt_osf: change %pi4 to %pI4
Date: Tue, 16 Feb 2010 15:55:30 +0100 (MET)
Message-ID: <20100216145528.2796.92232.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51963 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab0BPOzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:31 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7f635d0d1bf84ad7a0032cbce9d902b9384c48b7
Author: Joe Perches <joe@perches.com>
Date:   Mon Jan 11 11:55:36 2010 +0100

    netfilter: xt_osf: change %pi4 to %pI4
    
    commit 8a27f7c90ffcb791eed7574922b51fb60b08fc89
    changed the output style of %pi4 to use fixed
    width leading zero IP addresses "001.002.003.004".
    
    It's useful when printing multiple lines of
    addresses, but was a change in output style for
    some existing uses.
    
    Using %pI4 restores the previous output style.
    
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4d1a41b..4169e20 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -334,7 +334,7 @@ static bool xt_osf_match_packet(const struct sk_buff *skb,
 			if (info->flags & XT_OSF_LOG)
 				nf_log_packet(p->family, p->hooknum, skb,
 					p->in, p->out, NULL,
-					"%s [%s:%s] : %pi4:%d -> %pi4:%d hops=%d\n",
+					"%s [%s:%s] : %pI4:%d -> %pI4:%d hops=%d\n",
 					f->genre, f->version, f->subtype,
 					&ip->saddr, ntohs(tcp->source),
 					&ip->daddr, ntohs(tcp->dest),
@@ -349,7 +349,7 @@ static bool xt_osf_match_packet(const struct sk_buff *skb,
 
 	if (!fcount && (info->flags & XT_OSF_LOG))
 		nf_log_packet(p->family, p->hooknum, skb, p->in, p->out, NULL,
-			"Remote OS is not known: %pi4:%u -> %pi4:%u\n",
+			"Remote OS is not known: %pI4:%u -> %pI4:%u\n",
 				&ip->saddr, ntohs(tcp->source),
 				&ip->daddr, ntohs(tcp->dest));
 
