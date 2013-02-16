From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/4] VXLAN: TCP segmentation offload
Date: Fri, 15 Feb 2013 17:05:56 -0800
Message-ID: <1360976756-1792-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:59950 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750733Ab3BPBEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:04:15 -0500
Received: by mail-vb0-f72.google.com with SMTP id ft2so4821859vbb.7
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:04:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches add TCP segmentation offload to VXLAN. These
patches shows performance improvement from 3.8G to 5.8G (+50%)
with netperf single process TCP_STREAM test on 10G network.

Pravin B Shelar (4):
  net: Add skb_headers_offset_update helper function.
  tunneling: Capture inner mac header during encapsulation.
  tunneling: Add generic Tunnel segmentation.
  VXLAN: Use UDP Tunnel segmention.

 drivers/net/vxlan.c             |   23 +++++++--
 include/linux/netdev_features.h |    7 ++-
 include/linux/skbuff.h          |   36 ++++++++++++
 net/core/skbuff.c               |   36 ++++++-------
 net/ipv4/af_inet.c              |    6 ++-
 net/ipv4/udp.c                  |  113 ++++++++++++++++++++++++++++++---------
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |   10 +++-
 8 files changed, 177 insertions(+), 55 deletions(-)
