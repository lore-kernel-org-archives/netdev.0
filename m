From: Andy Zhou <azhou@nicira.com>
Subject: [v8 net-next 0/4] Refactor vxlan and l2tp to use new common UDP tunnel APIs
Date: Tue, 16 Sep 2014 17:29:43 -0700
Message-ID: <1410913787-31599-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:53826 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753039AbaIQAfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 20:35:23 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so886793pad.28
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:35:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add a few more UDP tunnel APIs and refactoring current
UDP tunnel based protocols, vxlan and l2tp to make use of the new APIs.

The added APIs are setup_udp_tunnel_sock(), udp_tunnel_xmit_skb() and 
udp_tunnel_sock_release(). Those implementation logics already exist in
current vxlan and l2tp implementation. Move them to common APIs to reduce
code duplications.

Also split udp_tunnel.c into net/ipv4/udp_tunnel.c and
net/ipv6/ip6_udp_tunnel.c to maintain proper IP protocol separation.

Andy Zhou (4):
  udp_tunnel: Seperate ipv6 functions into its own file.
  udp-tunnel: Add a few more UDP tunnel APIs
  vxlan: Refactor vxlan driver to make use of the common UDP tunnel
    functions.
  l2tp: Refactor l2tp core driver to make use of the common UDP tunnel
    functions

 drivers/net/vxlan.c       |  105 ++++++++--------------------------
 include/net/udp_tunnel.h  |   85 +++++++++++++++++++++++++++-
 net/ipv4/udp_tunnel.c     |  138 ++++++++++++++++++++++++---------------------
 net/ipv6/Makefile         |    1 +
 net/ipv6/ip6_udp_tunnel.c |  105 ++++++++++++++++++++++++++++++++++
 net/l2tp/l2tp_core.c      |   24 ++++----
 6 files changed, 294 insertions(+), 164 deletions(-)
 create mode 100644 net/ipv6/ip6_udp_tunnel.c

-- 
1.7.9.5
