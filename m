From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/netfilter/xt_osf.c: Change %pi4 to %pI4
Date: Wed, 06 Jan 2010 18:20:18 -0800
Message-ID: <1262830818.1872.52.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756521Ab0AGCUW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8a27f7c90ffcb791eed7574922b51fb60b08fc89
changed the output style of %pi4 to use fixed
width leading zero IP addresses "001.002.003.004".

It's useful when printing multiple lines of
addresses, but was a change in output style for
some existing uses.

Using %pI4 restores the previous output style.

Signed-off-by: Joe Perches <joe@perches.com>

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
 
