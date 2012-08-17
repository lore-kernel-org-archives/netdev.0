From: pablo@netfilter.org
Subject: [PATCH 0/2] netlink patches
Date: Fri, 17 Aug 2012 19:22:27 +0200
Message-ID: <1345224149-5946-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60260 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757730Ab2HQRXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2012 13:23:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi,

The following two patches contain one update to replace
netlink_set_nonroot and one RFC to resolve possible Netlink
spoofing from the kernel itself by disabling one of the Netlink
features (please, read [PATCH 2/2] for details).

The first patch removes the netlink_set_nonroot to use the recently
added struct netlink_kernel_cfg passed to netlink_kernel_create.

The second tries to address netlink spoofing for non-root processes
from the kernel while disabling the ability of two processes to
communicate. Yes, this may be controversial I guess.

Specifically for the second patch, please, let me know if I'm
missing anything that makes me reach bogus conclusions in the RFC
patch.

Thanks!

Pablo Neira Ayuso (2):
  netlink: kill netlink_set_nonroot
  [RFC] netlink: fix possible spoofing from non-root processes

 include/linux/netlink.h    |    9 ++++-----
 lib/kobject_uevent.c       |    2 +-
 net/core/rtnetlink.c       |    2 +-
 net/netlink/af_netlink.c   |   21 ++++++++-------------
 net/netlink/genetlink.c    |    3 +--
 security/selinux/netlink.c |    2 +-
 6 files changed, 16 insertions(+), 23 deletions(-)

-- 
1.7.10.4
