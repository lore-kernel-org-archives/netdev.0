From: kuznet@ms2.inr.ac.ru
Subject: Re: TCP/IPv6 broken in Linux 2.5.64?
Date: Thu, 20 Mar 2003 18:49:49 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200303201549.SAA10972@sex.inr.ac.ru>
References: <20030318162532.GA9705@outpost.ds9a.nl>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.NL (bert hubert)
In-Reply-To: <20030318162532.GA9705@outpost.ds9a.nl> from "bert hubert" at Mar 18, 3 07:45:02 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> irc servers, or an IPv6 zonetransfer. However, when I try to ssh from 2.5.65

Try this. I have just found this lost patch, it is from 2.4 tree, but
it should fit to 2.5 as well.

Alexey


===== net/ipv6/tcp_ipv6.c 1.19 vs edited =====
--- 1.19/net/ipv6/tcp_ipv6.c	Thu Jan 23 21:14:18 2003
+++ edited/net/ipv6/tcp_ipv6.c	Thu Mar 20 18:44:17 2003
@@ -983,7 +983,7 @@
 	struct ipv6_pinfo *np = &sk->net_pinfo.af_inet6;
 
 	if (skb->ip_summed == CHECKSUM_HW) {
-		th->check = csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
+		th->check = ~csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
 		skb->csum = offsetof(struct tcphdr, check);
 	} else {
 		th->check = csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP, 
