From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/3] v3 GRE: TCP segmentation offload
Date: Thu, 14 Feb 2013 11:44:41 -0800
Message-ID: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:60291 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759753Ab3BOADk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:03:40 -0500
Received: by mail-oa0-f70.google.com with SMTP id h2so15826008oag.5
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:03:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches add TCP segmentation offload to GRE. These 
patches shows 20-25% performance improvement in netperf single
process TCP_STREAM test on 10G network.

Pravin B Shelar (3):
  net: Add skb_unclone() helper function.
  net: factor out skb_mac_gso_segment() from skb_gso_segment()
  GRE: Add TCP segmentation offload for GRE

 drivers/net/ppp/ppp_generic.c           |    3 +-
 include/linux/netdev_features.h         |    3 +-
 include/linux/netdevice.h               |    2 +
 include/linux/skbuff.h                  |   27 +++++++
 net/core/dev.c                          |   80 ++++++++++++--------
 net/core/ethtool.c                      |    1 +
 net/core/skbuff.c                       |    6 +-
 net/ipv4/af_inet.c                      |    1 +
 net/ipv4/ah4.c                          |    3 +-
 net/ipv4/gre.c                          |  122 +++++++++++++++++++++++++++++++
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv4/ip_gre.c                       |   82 +++++++++++++++++++--
 net/ipv4/tcp.c                          |    1 +
 net/ipv4/tcp_output.c                   |    2 +-
 net/ipv4/udp.c                          |    3 +-
 net/ipv4/xfrm4_input.c                  |    2 +-
 net/ipv4/xfrm4_mode_tunnel.c            |    3 +-
 net/ipv6/ah6.c                          |    3 +-
 net/ipv6/ip6_offload.c                  |    1 +
 net/ipv6/netfilter/nf_conntrack_reasm.c |    2 +-
 net/ipv6/reassembly.c                   |    2 +-
 net/ipv6/udp_offload.c                  |    3 +-
 net/ipv6/xfrm6_mode_tunnel.c            |    3 +-
 net/sched/act_ipt.c                     |    6 +-
 net/sched/act_pedit.c                   |    3 +-
 25 files changed, 303 insertions(+), 63 deletions(-)
