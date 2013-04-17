From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4 0/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 13:10:17 +0800
Message-ID: <1366175423-27310-1-git-send-email-amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204Ab3DQFKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 01:10:33 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3H5AWja015879
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 01:10:33 -0400
Received: from cr0.sunraytvi.com (vpn1-115-1.nay.redhat.com [10.66.115.1])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r3H5ARnZ025015
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 01:10:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

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
  vxlan: add ipv6 support
  vxlan: add scope_id support for ll addr
  ipv6: Add generic UDP Tunnel segmentation

 drivers/net/vxlan.c          |  656 +++++++++++++++++++++++++++++++++---------
 include/uapi/linux/if_link.h |    2 +
 net/ipv6/ip6_offload.c       |    4 +-
 net/ipv6/mcast.c             |    2 +
 net/ipv6/udp_offload.c       |  155 +++++++---
 5 files changed, 633 insertions(+), 186 deletions(-)

-- 
1.7.7.6
