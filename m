From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 0/2] GRE: segmentation offload
Date: Thu, 24 Jan 2013 14:16:20 -0800
Message-ID: <1359065780-1730-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, eric.dumazet@gmail.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob106.obsmtp.com ([74.125.149.76]:53404 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1755659Ab3AXWPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 17:15:30 -0500
Received: by mail-ia0-f199.google.com with SMTP id u20so16903778iag.10
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 14:15:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds segmentation offload to GRE. I did performance
tests with netperf single TCP_STREAM tests, results are as follows
for GRE TAP device on 10G.

base kernel: 4043  10^6bits/sec
with patch:  4801  10^6bits/sec (+18.7)

This patch also address concerns that were raised in GRE csum discussion
(http://patchwork.ozlabs.org/patch/214665/). It avoids large skb allocation
in xmit path and improves performance as shown.

Pravin B Shelar (2):
  net: Add skb_unclone() helper function.
  GRE: Add segmentation offload for GRE

 drivers/net/ppp/ppp_generic.c           |    3 +-
 include/linux/netdevice.h               |    4 +-
 include/linux/skbuff.h                  |   20 ++++++
 net/core/dev.c                          |   59 ++++++++++-------
 net/core/skbuff.c                       |    7 +-
 net/ipv4/af_inet.c                      |    1 +
 net/ipv4/ah4.c                          |    3 +-
 net/ipv4/gre.c                          |  110 +++++++++++++++++++++++++++++++
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv4/ip_gre.c                       |   94 +++++++++++++++++++++-----
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
 23 files changed, 271 insertions(+), 66 deletions(-)

-- 
1.7.10
