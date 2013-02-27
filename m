From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 0/3] Provide default fdb operation to allow mac filter
Date: Wed, 27 Feb 2013 12:46:01 -0500
Message-ID: <1361987164-15280-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756718Ab3B0RqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 12:46:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a short series that now allows mac filter programming on any
card that support IFF_UNICAST_FLT by using the existing FDB interface.

Some existing drivers that had FDB functionality usually supported
it only in SR-IOV mode.  Since that's not always enabled, and
we want to take advantage of IFF_UNICAST_FLT support, these drivers
have been converted to call the default handler when not in SRIOV mode.

John Fastabend (1):
  net: generic fdb support for drivers without ndo_fdb_<op>

Vlad Yasevich (2):
  ixgbe: Use default fdb handlers when not in VF mode.
  mlx4: Use default fdb handlers when not multifunction.

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   26 +++-----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   12 +---
 include/linux/rtnetlink.h                      |    9 +++
 net/core/rtnetlink.c                           |   81 ++++++++++++++++++++++--
 4 files changed, 98 insertions(+), 30 deletions(-)

-- 
1.7.7.6
