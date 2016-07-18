From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH 0/2] net: Consider fragmentation of udp tunneled skbs in 'ip_finish_output_gso'
Date: Mon, 18 Jul 2016 14:49:32 +0300
Message-ID: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: shmulik.ladkani@ravellosystems.com,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31808 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRLud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:50:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently IP fragmentation of GSO segments that exceed dst mtu is
considered only in the ipv4 forwarding case.

There are cases where GSO skbs that are bridged and then udp-tunneled
may have gso_size exceeding the egress device mtu.
It makes sense to fragment them, as in the non GSOed code path.

The exact cases where this behavior is needed is described and addressed
in the 2nd patch.

Shmulik Ladkani (2):
  net/ipv4: Introduce IPSKB_FRAG_SEGS bit to inet_skb_parm.flags
  net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU,
    allow segmentation for local udp tunneled skbs

 include/net/ip.h          | 1 +
 net/ipv4/ip_forward.c     | 2 +-
 net/ipv4/ip_output.c      | 6 ++++--
 net/ipv4/ip_tunnel_core.c | 9 +++++++++
 net/ipv4/ipmr.c           | 2 +-
 5 files changed, 16 insertions(+), 4 deletions(-)

-- 
1.9.1
