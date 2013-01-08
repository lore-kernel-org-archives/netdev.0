From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v5 0/4] netpoll: add IPv6 support
Date: Tue,  8 Jan 2013 14:52:38 +0800
Message-ID: <1357627962-28683-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab3AHGww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 01:52:52 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r086qq2B019882
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 8 Jan 2013 01:52:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v5: move some ipv6 checksum functions into net/ipv6/ip6_checksum.c

v4: remove ndisc_parse_options(), ignore ICMP options there
    make udp6_csum_init() inline so that we don't rely on IPV6=y
    fix a conflict with Jiri's patchset

v3: fix CONFIG_IPV6=m case
 
v2: use bool for ipv6 flag
    fix !CONFIG_IPV6 case

This patchset implements netpoll over IPv6.

Cong Wang (4):
  netpoll: prepare for ipv6
  ipv6: move csum_ipv6_magic() and udp6_csum_init() into static library
  netpoll: add IPv6 support
  netconsole: add IPv6 example in doc

 Documentation/networking/netconsole.txt |    7 +-
 drivers/net/netconsole.c                |   44 ++-
 include/linux/netpoll.h                 |   13 +-
 include/net/ip6_checksum.h              |   62 +---
 net/core/netpoll.c                      |  622 ++++++++++++++++++++++---------
 net/ipv6/Makefile                       |    2 +-
 net/ipv6/ip6_checksum.c                 |   97 +++++
 net/ipv6/udp.c                          |   34 --
 8 files changed, 607 insertions(+), 274 deletions(-)

-- 
1.7.7.6
