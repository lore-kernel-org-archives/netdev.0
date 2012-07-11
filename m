From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 0/5] cgroup cls & netprio 'cleanups'
Date: Wed, 11 Jul 2012 11:35:36 +0200
Message-ID: <1341999341-1808-1-git-send-email-wagi@monom.org>
Cc: netdev@vger.kernel.org, Daniel Wagner <daniel.wagner@bmw-carit.de>
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:58337 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab2GKJfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 05:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Hi,

While looking a bit at the cls and netprio controller I found a
few things which I think are 'not optimal'.

The first patch makes sock_update_netprioidx() a bit smatter, so that
only on changed value the sk->sk_cgroup_prioidx is written and not
all the time.

The next two patches are changing the built. In case someone 
builds a kernel with cgroup support but disabled cls or netprio
controller, there was still code added.

And the last two patches change the cls and netprio source files in
that way, that the use IS_BUILTIN and IS_MODULE as it used in the
header files.

The patches are against net-next.

cheers,
daniel

Daniel Wagner (5):
  cgroup: Only update sk_cgrp_prioidx on change
  cgroup: Do not add sock_update_classid() when CONFIG_NET_CLS_CGROUP=0
  cgroup: Do not add sock_update_netprioidx() when
    CONFIG_NETPRIO_CGROUP=0
  cgroup: Make builtin vs. module build ifdefs consistent
  cgroup: Make builtin vs. module build ifdefs consistent

 include/net/cls_cgroup.h     | 33 +++++++++++++++++++++++----------
 include/net/netprio_cgroup.h | 31 ++++++++++++++-----------------
 include/net/sock.h           |  8 --------
 net/core/netprio_cgroup.c    |  6 +++---
 net/core/sock.c              | 14 +++++++++++---
 net/sched/cls_cgroup.c       |  6 +++---
 6 files changed, 54 insertions(+), 44 deletions(-)

-- 
1.7.11.1.165.g299666c
