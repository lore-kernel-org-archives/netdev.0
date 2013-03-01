From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 0/4] Provide default fdb operation to allow mac filter setting
Date: Fri,  1 Mar 2013 10:31:42 -0500
Message-ID: <1362151906-20993-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601Ab3CAPbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 10:31:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a short series that now allows mac filter programming on any
card that support IFF_UNICAST_FLT by using the existing FDB interface.

Some existing drivers that had FDB functionality usually supported
it only in SR-IOV mode.  Since that's not always enabled, and
we want to take advantage of IFF_UNICAST_FLT support, these drivers
have been converted to call the default handler when not in SRIOV mode.

Changes since v1:
 - Restore ixgbe implementation of fdb_add since it needs to 
   enforce the limit of addresses in SR-IOV case.

Changes since RFC:
 - Removed ixgbe and mlx versions of fdb calls as recommened.
 - Added qlogic patch to use default calls when module parameter is
   not turned on.

Vlad Yasevich (4):
  net: generic fdb support for drivers without ndo_fdb_<op>
  ixgbe: Remove driver specific fdb handlers.
  mlx4: Remove driver specific fdb handlers.
  qlcnic: Use generic fdb handler when driver options are not enabled.

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   42 +-----------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   76 --------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   21 ++----
 include/linux/rtnetlink.h                        |    9 +++
 net/core/rtnetlink.c                             |   81 ++++++++++++++++++++--
 5 files changed, 91 insertions(+), 138 deletions(-)

-- 
1.7.7.6
