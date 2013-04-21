From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Sun, 21 Apr 2013 22:23:07 +0800
Message-ID: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588Ab3DUOXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Apr 2013 10:23:42 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3LENgWb008619
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sun, 21 Apr 2013 10:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

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

Cong Wang (5):
  vxlan: defer vxlan init as late as possible
  ipv6: export ipv6_sock_mc_join and ipv6_sock_mc_drop
  ipv6: export in6addr_loopback to modules
  vxlan: add ipv6 support
  ipv6: Add generic UDP Tunnel segmentation

 drivers/net/vxlan.c          |  625 ++++++++++++++++++++++++++++++++---------
 include/uapi/linux/if_link.h |    2 +
 net/ipv6/addrconf.c          |    9 -
 net/ipv6/addrconf_core.c     |    9 +
 net/ipv6/ip6_offload.c       |    4 +-
 net/ipv6/mcast.c             |    2 +
 net/ipv6/udp_offload.c       |  153 +++++++----
 7 files changed, 609 insertions(+), 195 deletions(-)

-- 
1.7.7.6
