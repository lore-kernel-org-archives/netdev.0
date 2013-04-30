From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v7 0/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 16:43:09 +0800
Message-ID: <1367311395-15891-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759146Ab3D3Inb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 04:43:31 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3U8hUAF013413
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 04:43:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Cong Wang (6):
  vxlan: defer vxlan init as late as possible
  ipv6: export a stub for ipv6_sock_mc_join and ipv6_sock_mc_drop
  ipv6: export in6addr_loopback to modules
  vxlan: add ipv6 support
  vxlan: respect disable_ipv6 sysctl
  ipv6: Add generic UDP Tunnel segmentation

 drivers/net/vxlan.c          |  662 +++++++++++++++++++++++++++++++++---------
 include/net/addrconf.h       |    9 +
 include/uapi/linux/if_link.h |    2 +
 net/ipv6/addrconf.c          |    9 -
 net/ipv6/addrconf_core.c     |   13 +
 net/ipv6/ip6_offload.c       |    4 +-
 net/ipv6/mcast.c             |    7 +
 net/ipv6/udp_offload.c       |  153 +++++++---
 8 files changed, 664 insertions(+), 195 deletions(-)

-- 
1.7.7.6
