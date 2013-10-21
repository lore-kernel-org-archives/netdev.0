From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] ipv6: sit: Implement TSO/GSO support
Date: Sun, 20 Oct 2013 20:47:28 -0700
Message-ID: <1382327251-21079-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Erik Kline <ek@google.com>, Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:56788 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab3JUDrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 23:47:52 -0400
Received: by mail-pd0-f201.google.com with SMTP id y10so380943pdj.4
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 20:47:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch serie implements GSO/TSO support for SIT tunnels

Broadcom bnx2x driver is now enabled for TSO support of SIT traffic

Before patches :

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      3168.31   4.81     4.64     2.988   2.877

After patches :

lpq84:~# ./netperf -H 2002:af6:1153:: -Cc
MIGRATED TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:1153:: () port 0 AF_INET6
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      6006.97   1.86     5.48     0.608   1.795

Eric Dumazet (3):
  ipv6: gso: make ipv6_gso_segment() stackable
  ipv6: sit: add GSO/TSO support
  bnx2x: add TSO support for SIT tunnels

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  3 ++-
 include/linux/netdev_features.h                  |  2 ++
 include/linux/skbuff.h                           |  6 +++--
 net/core/ethtool.c                               |  1 +
 net/ipv4/af_inet.c                               |  1 +
 net/ipv4/tcp_offload.c                           |  1 +
 net/ipv6/ip6_offload.c                           | 34 +++++++++++++++++++-----
 net/ipv6/sit.c                                   | 28 ++++++++++++-------
 net/ipv6/udp_offload.c                           |  1 +
 9 files changed, 59 insertions(+), 18 deletions(-)

-- 
1.8.4
