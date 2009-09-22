From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 12/13] TProxy: added IPv6 support to the socket match
Date: Tue, 22 Sep 2009 10:33:46 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0909221032290.22568@obet.zrqbmnf.qr>
References: <1253548005.12519.12.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1253548005.12519.12.camel@bzorp.balabit>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2009-08-24 14:52, Balazs Scheidler wrote:

>+static bool
>+socket_mt6_v1(const struct sk_buff *skb, const struct xt_match_param *par)
>+{
>+	struct ipv6hdr *iph = ipv6_hdr(skb);
>+	struct udphdr _hdr, *hp = NULL;
>+	struct sock *sk;
>+	struct in6_addr *daddr, *saddr;
>+	__be16 dport, sport;
>+        int thoff;
>+	u8 tproto;
>+        const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
>+        
>+        tproto = ipv6_find_hdr(skb, &thoff, -1, NULL);
>+        if (tproto < 0) {
>+		pr_debug("socket match: Unable to find transport header in IPv6 packet, dropping\n");
>+		return NF_DROP;
>+        }
>+
>+	if (tproto == IPPROTO_UDP || tproto == IPPROTO_TCP) {

The tabbing seems off (also noticed this in other patches,
pcregrep for '^ {8}' )
