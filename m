From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v5 0/3] Refactor vxlan and l2tp to use common UDP tunnel APIs
Date: Wed, 10 Sep 2014 20:29:50 -0700
Message-ID: <1410406193-6185-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:58142 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750967AbaIKDf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 23:35:29 -0400
Received: by mail-pd0-f172.google.com with SMTP id v10so13536970pde.31
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 20:35:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series expend current UDP tunnel APIs and refactoring current
UDP tunnel based protocols to make use of the new APIs. The main motivation
is to reduce code duplication.

*** BLURB HERE ***

Andy Zhou (3):
  udp-tunnel: Expand UDP tunnel APIs
  vxlan: Refactor vxlan driver to make use of the common UDP tunnel
    functions.
  l2tp: Refactor l2tp core driver to make use of the common UDP tunnel 
       functions

 drivers/net/vxlan.c           |  174 ++++++++++++++--------------------
 include/net/udp_tunnel.h      |   73 +++++++++++++++
 include/net/vxlan.h           |   17 ++--
 net/ipv4/Kconfig              |    1 +
 net/ipv4/udp_tunnel.c         |  108 ++++++++++++++-------
 net/ipv6/Makefile             |    1 +
 net/ipv6/ip6_udp_tunnel.c     |  121 ++++++++++++++++++++++++
 net/l2tp/l2tp_core.c          |  208 +++++++++++++++++++++++++----------------
 net/openvswitch/vport-vxlan.c |    6 +-
 9 files changed, 480 insertions(+), 229 deletions(-)
 create mode 100644 net/ipv6/ip6_udp_tunnel.c

-- 
1.7.9.5
