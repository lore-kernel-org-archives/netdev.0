From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Mon, 27 May 2013 12:16:22 +0800
Message-ID: <1369628193-14925-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748Ab3E0EQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 00:16:47 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4R4Gk2D029680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 27 May 2013 00:16:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

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
  vxlan: defer vxlan init as late as possible
  vxlan: use unsigned int instead of unsigned
  ipv6: make ip6_dst_hoplimit() static inline
  ipv6: move ip6_local_out into core kernel
  ipv6: export a stub for IPv6 symbols used by vxlan
  ipv6: export in6addr_loopback to modules
  vxlan: add ipv6 support
  vxlan: add ipv6 route short circuit support
  vxlan: add ipv6 proxy support
  vxlan: respect scope_id for ll addr
  ipv6: Add generic UDP Tunnel segmentation

 drivers/net/vxlan.c          |  854 ++++++++++++++++++++++++++++++++++--------
 include/net/addrconf.h       |   18 +
 include/net/ip6_route.h      |   23 +-
 include/net/ndisc.h          |    5 +
 include/uapi/linux/if_link.h |    2 +
 net/ipv6/addrconf.c          |    9 -
 net/ipv6/addrconf_core.c     |   13 +
 net/ipv6/af_inet6.c          |   12 +
 net/ipv6/ip6_offload.c       |    4 +-
 net/ipv6/ip6_output.c        |   25 --
 net/ipv6/ndisc.c             |    8 +-
 net/ipv6/output_core.c       |   26 ++
 net/ipv6/route.c             |   19 -
 net/ipv6/udp_offload.c       |  153 +++++---
 14 files changed, 909 insertions(+), 262 deletions(-)

-- 
1.7.7.6
