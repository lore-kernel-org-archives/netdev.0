From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 00/11] vxlan: add ipv6 support
Date: Wed, 28 Aug 2013 13:22:48 +0800
Message-ID: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568Ab3H1FXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

v10: rebase on the latest net-next
     fix a deadlock, which didn't exist before
     fix another compile error when IPV6=m
     some cleanup

v9: rebase on the latest net-next
    adjust coding style to make DaveM happy
    merge disable_ipv6 patch into the previous one
    add a cleanup patch

v8: fix the bug when bindv6only=1
    fix more compile errors when IPV6=m
    complete the rest missing features for IPv6

v7: respect disable_ipv6 flag
    back to ipv4 only when ipv6 is not supported

v6: use a stub for IPv6 mcast functions
    split a few more long lines
    rebased on the latest net-next

v5: make David happy on the names of the fields
    fix my mistake during rebasing the patches
    drop the scope_id patch, because it is broken
    export in6addr_loopback
    fix a udp checksum bug
    rebased on the latest net-next

v4: rename ->sin to ->va_sin
    rename ->sin6 to ->va_sin6
    rename ->family to ->va_sa
    support ll addr
    fix more ugly #ifdef
    rebased on the latest net-next

v3: fix many coding style issues
    fix some ugly #ifdef
    rename vxlan_ip to vxlan_addr
    rename ->proto to ->family
    rename ->ip4/->ip6 to ->sin/->sin6

v2: fix some compile error when !CONFIG_IPV6
    improve some code based on Stephen's comments
    use sockaddr suggested by David

Cong Wang (11):
  ipv6: make ip6_dst_hoplimit() static inline
  ipv6: move ip6_local_out into core kernel
  ipv6: export a stub for IPv6 symbols used by vxlan
  ipv6: export in6addr_loopback to modules
  ipv6: do not call ndisc_send_rs() with write lock
  vxlan: add ipv6 support
  vxlan: add ipv6 route short circuit support
  ipv6: move in6_dev_finish_destroy() into core kernel
  vxlan: add ipv6 proxy support
  vxlan: respect scope_id for ll addr
  ipv6: Add generic UDP Tunnel segmentation

 drivers/net/vxlan.c           |  876 ++++++++++++++++++++++++++++++++++-------
 include/net/addrconf.h        |   20 +
 include/net/ip6_route.h       |   23 +-
 include/net/ndisc.h           |    5 +
 include/net/vxlan.h           |    2 +-
 include/uapi/linux/if_link.h  |    2 +
 net/ipv6/addrconf.c           |   49 +--
 net/ipv6/addrconf_core.c      |   50 +++
 net/ipv6/af_inet6.c           |   14 +
 net/ipv6/ip6_offload.c        |    4 +-
 net/ipv6/ip6_output.c         |   25 --
 net/ipv6/ndisc.c              |    8 +-
 net/ipv6/output_core.c        |   26 ++
 net/ipv6/route.c              |   19 -
 net/ipv6/udp_offload.c        |  159 +++++---
 net/openvswitch/vport-vxlan.c |    2 +-
 16 files changed, 988 insertions(+), 296 deletions(-)

-- 
1.7.7.6
