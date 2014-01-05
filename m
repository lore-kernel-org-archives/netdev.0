From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Sat, 04 Jan 2014 17:33:08 -0800
Message-ID: <1388885588.12212.158.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388813047-5262-1-git-send-email-hkchu@google.com>
	 <20140104.200931.524755895829922293.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:47625 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbaAEBdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:33:11 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so17046891pbc.21
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 17:33:10 -0800 (PST)
In-Reply-To: <20140104.200931.524755895829922293.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-04 at 20:09 -0500, David Miller wrote:
> From: "H.K. Jerry Chu" <hkchu@google.com>
> Date: Fri,  3 Jan 2014 21:24:07 -0800
> 
> > +struct packet_offload *gro_find_receive_by_type(__be16 type);
> > +struct packet_offload *gro_find_complete_by_type(__be16 type);
> 
> You're not exporting these to modules, therefore if GRE is built
> modular it won't work.


Ah, I see now net/ipv4/gre_offload.c is not statically included.

This is unfortunate, as GRO/GSO should be fully enabled on routers, even
if no GRE tunnel is setup on the host.

Whole point of moving this stuff in separate gre_offload.c (commit
c50cd357887ac "net: gre: move GSO functions to gre_offload") was offer
offload capabilities without having to load GRE module.

diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4b81e91c80fe..f8c49ce5b283 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
@@ -19,7 +19,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
-gre-y := gre_demux.o gre_offload.o
+gre-y := gre_demux.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
