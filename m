From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3 net-next 0/2] sit: allow to switch netns during encap/decap
Date: Wed, 26 Jun 2013 16:11:26 +0200
Message-ID: <1372255888-4792-1-git-send-email-nicolas.dichtel@6wind.com>
References: <51CADB72.3090206@6wind.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:43630 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467Ab3FZOL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 10:11:59 -0400
In-Reply-To: <51CADB72.3090206@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch is a follow up of the thread "switching network namespace midway":
http://marc.info/?t=135101459500004&r=1&w=2

The goal of this serie is to add x-netns support for the module sit, ie the
encapsulation addresses and the network device are not owned by the same
namespace.

Example to configure a tunnel:

modprobe sit
ip netns add netns1
ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
ip l s sit1 netns netns1
ip netns exec netns1 ip l s lo up
ip netns exec netns1 ip l s sit1 up
ip netns exec netns1 ip a a dev sit1 192.168.2.123 remote 192.168.2.121
ip netns exec netns1 ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121

Once this serie is approved, I will add the same feature for the module ipip and
ip6_tunnel.

v3:
  put again the test about netns before calling skb_scrub_packet()
  add a missing skb_scrub_packet() call in ip_tunnel_xmit()

v2:
  rename dev_cleanup_skb to skb_scrub_packet
  move skb_scrub_packet to skbuff.c
  fix netns cleanup
  remove string comparison in netns cleanup
  add a comment about FB device
  call skb_scrub_packet() unconditionnaly
  remove 'RFC'

 include/linux/skbuff.h   |  1 +
 include/net/ip_tunnels.h |  1 +
 net/core/dev.c           | 11 +----------
 net/core/skbuff.c        | 23 +++++++++++++++++++++++
 net/ipv4/ip_tunnel.c     | 10 +++++++++-
 net/ipv6/sit.c           | 42 ++++++++++++++++++++++++++++++++----------
 6 files changed, 67 insertions(+), 21 deletions(-)

Comments are welcome.

Regards,
Nicolas
