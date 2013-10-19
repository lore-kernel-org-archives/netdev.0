From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/6] net: Implement GSO/TSO support for IPIP
Date: Sat, 19 Oct 2013 11:42:52 -0700
Message-ID: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:45260 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3JSSsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:48:36 -0400
Received: by mail-ob0-f202.google.com with SMTP id va2so312189obc.1
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:48:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie implements GSO/TSO support for IPIP

David, please note it applies after "ipv4: gso: send_check() & segment() cleanups"
( http://patchwork.ozlabs.org/patch/284714/ )

Broadcom bnx2x driver is now enabled for TSO support of IPIP traffic

Before patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      3357.88   5.09     3.70     2.983   2.167

After patch :

lpq83:~# ./netperf -H 7.7.9.84 -Cc
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.9.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      8532.40   2.55     7.73     0.588   1.781
    

Eric Dumazet (6):
  ipv4: gso: send_check() & segment() cleanups
  net: generalize skb_segment()
  ipv4: generalize gre_handle_offloads
  ipv4: gso: make inet_gso_segment() stackable
  ipip: add GSO/TSO support
  bnx2x: add TSO support for IPIP

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  4 +-
 include/linux/netdev_features.h                  |  2 +
 include/linux/skbuff.h                           | 13 ++++--
 include/net/gre.h                                |  8 +++-
 include/net/ip_tunnels.h                         |  3 ++
 net/core/dev.c                                   |  2 +
 net/core/ethtool.c                               |  1 +
 net/core/skbuff.c                                | 22 ++-------
 net/ipv4/af_inet.c                               | 58 ++++++++++++++++--------
 net/ipv4/gre_demux.c                             | 29 ------------
 net/ipv4/gre_offload.c                           |  3 +-
 net/ipv4/ip_tunnel_core.c                        | 33 ++++++++++++++
 net/ipv4/ipip.c                                  | 11 +++--
 net/ipv4/tcp_offload.c                           |  1 +
 net/ipv4/udp_offload.c                           |  1 +
 net/ipv6/ip6_offload.c                           |  1 +
 net/ipv6/udp_offload.c                           |  1 +
 net/mpls/mpls_gso.c                              |  1 +
 18 files changed, 116 insertions(+), 78 deletions(-)

-- 
1.8.4
