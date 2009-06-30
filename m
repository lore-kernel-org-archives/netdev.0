From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Tue, 30 Jun 2009 23:30:42 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906302303350.27569@fbirervta.pbzchgretzou.qr>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr>
 <20090701062737.6cac2193.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	markmc@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, bdschuym@pandora.be
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34610 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbZF3Vak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 17:30:40 -0400
In-Reply-To: <20090701062737.6cac2193.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-06-30 22:57, Mark Smith wrote:
>>> 
>>> does conntrack ever make sense for bridging? Perhaps
>>> we should get rid of that completely?
>> 
>> It makes sense absolutely. Consider:
>> 
>> * packet enters bridge
>> * NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, ...) is called by nr_netfilter.c
>> * (connection tracking entry is set up)
>> * let bridging decision be "local delivery"
>quite a lot by it, due to it's quite strange side effects on traffic.
>e.g. it'll defragment bridged IP packets[...]

Hm not good. Then again, Netfilter does not know where the packet comes
from or where it goes, and Bridge does not know that Conntrack is
(potentially, it even varies) part of PREROUTING.

>I'm not sure if it supposed to work on IP traffic carried within
>bridge PPPoE/PPP, but it does

Bridge unpacks such frames if I've seen the code right :-/

        if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
            IS_PPPOE_IPV6(skb)) {
                nf_bridge_pull_encap_header_rcsum(skb);
                return br_nf_pre_routing_ipv6(hook, skb, in, out, okfn);
        }

I, too, wonder, why it would unpack PPP here.

However, there is a sysctl flag called vlan_tagged/pppoe_tagged which 
you can se to zero to not pull_encap VLAN/PPP.
