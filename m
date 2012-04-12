From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v3 0/8] Managing the forwarding database(FDB)
Date: Thu, 12 Apr 2012 10:06:45 -0700
Message-ID: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18467 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab2DLRTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 13:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series is a submission for net-next to allow
embedded switches and other stacked devices other then the
Linux bridge to manage a forwarding database.

Previously posted and discussed here,

http://lists.openwall.net/netdev/2012/03/19/26

Sorry for the thrash on v2 this version resolves the macvlan
patch 8/8 to fix a dev_set_promiscuity() error and add the
flags field to change and get link routines.

v2 addressed feedback from Ben Hutchings resolving a typo
in the multicast add/del routines and improving the error
handling when both NTF_SELF and NTF_MASTER are set.

As always thanks for the feedback and any comments welcom.
I've tested this with 'br' tool published by Stephen Hemminger
soon to be renamed 'bridge' I believe and various traffic
generators mostly pktgen, ping, and netperf.

Thanks!
John

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
 drivers/net/macvlan.c                         |   73 ++++++-
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
 13 files changed, 579 insertions(+), 173 deletions(-)

-- 
Signature
