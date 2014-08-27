From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 17:31:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408271625500.2348@ja.home.ssi.bg>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>   <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>   <20140822.105405.1982870131653082781.davem@davemloft.net>  <1409130792.2505.5.camel@jlt4.sipsolutions.net>
 <alpine.LFD.2.11.1408271255230.2348@ja.home.ssi.bg> <1409138967.2505.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39635 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933802AbaH0Odb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 10:33:31 -0400
In-Reply-To: <1409138967.2505.11.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 27 Aug 2014, Johannes Berg wrote:

> On Wed, 2014-08-27 at 13:23 +0300, Julian Anastasov wrote:
> 
> > BTW, what kind of packets (protocol) we want to drop? UDP?
> 
> All IP protocols, this comes either from the IPv4 RFC (1122) or from the
> wireless issue which affects all protocols.

	I did a grep for inet_add_protocol, in case if
we prefer to use per-protocol checks:

Protocols that look ok to me: TCP, SCTP, DCCP

ICMP: missing check in icmp_rcv
UDP, UDPLITE: need check in __udp4_lib_rcv
IGMP: uses only multicast address?
PIM: not sure if __pim_rcv() needs check, before skb_tunnel_rx()
	changes pkt_type?

More protocols are also registered with inet_add_protocol(), I don't
see pkt_type checks there, mostly tunnels:
- IPPROTO_GRE
- IPPROTO_L2TP
- IPPROTO_IPIP
- IPPROTO_IPV6 (tunnel64_rcv)

	If going to use a global check I hope there are
no protocols that require exception to this rule.

Regards

--
Julian Anastasov <ja@ssi.bg>
