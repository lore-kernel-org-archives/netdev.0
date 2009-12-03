From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/7] Batched netns improvements.
Date: Thu, 03 Dec 2009 04:27:08 -0800
Message-ID: <m11vjcnsyr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56084 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbZLCM1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:27:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This series of patches takes my simple 4k network namespace exit test
from about 44s to 1.6s, with a minuscule increase in code side.

While batching has given me big improvements there are a few
changes in there that improve the performance of cleaning up
a single network namespace.

Eric

 include/net/fib_rules.h          |    3 +-
 include/net/inet_timewait_sock.h |    6 +-
 include/net/net_namespace.h      |    2 +
 include/net/netns/xfrm.h         |    1 +
 net/core/dev.c                   |   25 +++++++
 net/core/fib_rules.c             |   36 +++++++++-
 net/core/net_namespace.c         |  138 ++++++++++++++++----------------------
 net/decnet/dn_rules.c            |   22 +++---
 net/ipv4/fib_rules.c             |   12 +---
 net/ipv4/inet_timewait_sock.c    |   45 ++++++++-----
 net/ipv4/tcp_ipv4.c              |   11 ++-
 net/ipv6/fib6_rules.c            |   22 ++----
 net/ipv6/tcp_ipv6.c              |   11 ++-
 net/xfrm/xfrm_user.c             |   18 +++--
 14 files changed, 200 insertions(+), 152 deletions(-)
