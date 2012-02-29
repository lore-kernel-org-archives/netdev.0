From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH 0/3] net: bridge: propagate FDB table into hardware
Date: Tue, 28 Feb 2012 23:17:08 -0800
Message-ID: <20120229070418.10937.8692.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, bhutchings@solarflare.com, roprabhu@cisco.com,
	mst@redhat.com, netdev@vger.kernel.org, gregory.v.rose@intel.com,
	davem@davemloft.net
To: jhs@mojatatu.com, shemminger@vyatta.com, kernel@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59601 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030751Ab2B2H3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Feb 2012 02:29:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is a follow up to the RFC thread with the same title.
It is intended to manage the forwarding database in embedded
switches One specific example being SR-IOV NICs.

This adds a private netdev flag (IFF_OFFLOADED_FDB) to enable
management of the FDB and a ndm_flags bit to set in the PF_BRIDGE
netlink commands to push the command at the embedded device.

As it is currently implemented this requires loading the bridge
module but has the advantage that the HW and SW FDB commands look
the same. It was easy for example to modify existing user space
tools to support this.

At this point I've only lightly tested it and need to audit the
code in the light of day. But any comments would appreciated it. I
figured pushing code out was easier then continuing a thread about
hypothetical solutions.

Thanks!

---

John Fastabend (3):
      net: drivers: set IFF_OFFLOADED_FDB priv flag on ixgbe and igb
      net: expose ebridge FDB with priv flag IFF_OFFLOADED_FDB
      net: refactor br_fdb_xxx rtnetlink routines


 drivers/net/ethernet/intel/igb/igb_main.c     |    2 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 
 include/linux/if.h                            |    2 
 include/linux/neighbour.h                     |    2 
 net/bridge/br_fdb.c                           |   88 +++------
 net/bridge/br_netlink.c                       |  237 ++++++++++++++++++++++++-
 net/bridge/br_private.h                       |    9 +
 7 files changed, 269 insertions(+), 75 deletions(-)

-- 
Signature
