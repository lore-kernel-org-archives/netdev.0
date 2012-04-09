From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1 0/7] Managing the forwarding database(FDB)
Date: Mon, 09 Apr 2012 15:00:11 -0700
Message-ID: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com, sri@us.ibm.com
To: roprabhu@cisco.com, mst@redhat.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757173Ab2DIWNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 18:13:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a submission for net-next to allow
embedded switches and other stacked devices other then the
Linux bridge to manage a forwarding database.

This was previously posted here (where it was deferred for
more review and testing)

http://lists.openwall.net/netdev/2012/03/19/26

This series adds macvlan support per discussions with Roopa
and Michael. Also ixgbe was updated to support adding multicast
addresses per request from Greg Rose.

Finally cleanups in the generic dump routines were added
for multicast to support ixgbe and macvlan use cases.

Thanks to everyone for the helpful review and comments. As
always any comments/feedback welcome.

.John

---

Greg Rose (1):
      ixgbe: UTA table incorrectly programmed

John Fastabend (6):
      macvlan: add FDB bridge ops and new macvlan mode
      ixgbe: allow RAR table to be updated in promisc mode
      ixgbe: enable FDB netdevice ops
      net: add fdb generic dump routine
      net: addr_list: add exclusive dev_uc_add and dev_mc_add
      net: add generic PF_BRIDGE:RTM_ FDB hooks


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  121 ++++++++++----
 drivers/net/macvlan.c                         |   60 ++++++-
 include/linux/if_link.h                       |    1 
 include/linux/neighbour.h                     |    3 
 include/linux/netdevice.h                     |   28 +++
 include/linux/rtnetlink.h                     |    4 
 net/bridge/br_device.c                        |    3 
 net/bridge/br_fdb.c                           |  128 ++++-----------
 net/bridge/br_netlink.c                       |   12 -
 net/bridge/br_private.h                       |   15 +-
 net/core/dev_addr_lists.c                     |   97 ++++++++++--
 net/core/rtnetlink.c                          |  209 +++++++++++++++++++++++++
 12 files changed, 508 insertions(+), 173 deletions(-)

-- 
Signature
