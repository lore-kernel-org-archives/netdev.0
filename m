From: Eric Dumazet <edumazet@google.com>
Subject: [RFC net-next 0/2] udp: use standard RCU rules
Date: Fri, 25 Mar 2016 15:29:22 -0700
Message-ID: <1458944964-12890-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34956 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435AbcCYW32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:29:28 -0400
Received: by mail-pa0-f46.google.com with SMTP id td3so54015298pab.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 15:29:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a generic facility for sockets to be freed afer an RCU grace period.

Then UDP is changed to no longer use SLAB_DESTROY_BY_RCU,
in order to speedup rx processing for traffic encapsulated in UDP.

I prepared a patch to convert TCP listeners to this infrastructure,
but will post it later, since Tom was mostly interested in UDP.

Eric Dumazet (2):
  net: add SOCK_RCU_FREE socket flag
  udp: No longer use SLAB_DESTROY_BY_RCU

 include/linux/udp.h |   8 +-
 include/net/sock.h  |  14 +--
 include/net/udp.h   |   2 +-
 net/core/sock.c     |  14 ++-
 net/ipv4/udp.c      | 290 +++++++++++++++-------------------------------------
 net/ipv4/udp_diag.c |  18 ++--
 net/ipv6/udp.c      | 194 +++++++++++------------------------
 7 files changed, 177 insertions(+), 363 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
