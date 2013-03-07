From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/4] VXLAN: segmentation offload
Date: Thu,  7 Mar 2013 15:21:30 -0800
Message-ID: <1362698490-2378-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:46317 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755660Ab3CGXUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 18:20:07 -0500
Received: by mail-qe0-f71.google.com with SMTP id 9so1827262qea.10
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 15:20:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches add segmentation offload to VXLAN. These
patches shows performance improvement from 3.9G to 5.8G (+50%)
with netperf single process TCP_STREAM test on 10G network.

Pravin B Shelar (4):
  net: Add skb_headers_offset_update helper function.
  tunneling: Capture inner mac header during encapsulation.
  tunneling: Add generic Tunnel segmentation.
  VXLAN: Use UDP Tunnel segmention.

 drivers/net/vxlan.c             |   21 ++++++-
 include/linux/netdev_features.h |    7 +-
 include/linux/skbuff.h          |   36 ++++++++++++
 net/core/ethtool.c              |    1 +
 net/core/skbuff.c               |   36 +++++-------
 net/ipv4/af_inet.c              |    6 ++-
 net/ipv4/tcp.c                  |    1 +
 net/ipv4/udp.c                  |  116 ++++++++++++++++++++++++++++++--------
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |   10 +++-
 10 files changed, 181 insertions(+), 54 deletions(-)
