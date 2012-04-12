From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 0/8] Managing the forwarding database(FDB)
Date: Wed, 11 Apr 2012 23:57:07 -0700
Message-ID: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35054 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DLHKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 03:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a submission for net-next to allow
embedded switches and other stacked devices other then the
Linux bridge to manage a forwarding database.

Previously posted and discussed here,

http://lists.openwall.net/netdev/2012/03/19/26

This version addresses feedback from Ben Hutchings to fix
a typo in the multicast dump routines and to better handle
error cases on add/del fdb. Notify hooks were added for
the NTF_SELF case as well to bring it inline with the
SW net/bridge.

Additionally this version changes the macvlan patch to use
a flag to disable promisc mode. This was decided on over
adding additional modes.

Thanks for the feedback and review. I've tested this with
the 'br' tool published by Stephen Hemminger and pktgen.

.John

---

Greg Rose (1):
      ixgbe: UTA table incorrectly programmed

John Fastabend (7):
      macvlan: add FDB bridge ops and macvlan flags
      ixgbe: allow RAR table to be updated in promisc mode
      ixgbe: enable FDB netdevice ops
      net: rtnetlink notify events for FDB NTF_SELF adds and deletes
      net: add fdb generic dump routine
      net: addr_list: add exclusive dev_uc_add and dev_mc_add
      net: add generic PF_BRIDGE:RTM_ FDB hooks


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  121 ++++++++---
 drivers/net/macvlan.c                         |   61 +++++-
 include/linux/if_link.h                       |    3 
 include/linux/if_macvlan.h                    |    1 
 include/linux/neighbour.h                     |    3 
 include/linux/netdevice.h                     |   25 ++
 include/linux/rtnetlink.h                     |    4 
 net/bridge/br_device.c                        |    3 
 net/bridge/br_fdb.c                           |  128 +++---------
 net/bridge/br_netlink.c                       |   12 -
 net/bridge/br_private.h                       |   15 +
 net/core/dev_addr_lists.c                     |   97 ++++++++-
 net/core/rtnetlink.c                          |  267 +++++++++++++++++++++++++
 13 files changed, 567 insertions(+), 173 deletions(-)

-- 
Signature
