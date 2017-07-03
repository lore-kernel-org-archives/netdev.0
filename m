From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 00/27] RDMA Netlink Device Client
Date: Mon,  3 Jul 2017 09:28:03 +0300
Message-ID: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59206 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751902AbdGCG2i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:28:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is third version of the RDMA netlink patch set.

The following patch set is an implementation of NLDEV - RDMA netlink
device client. It is based on the already sent patch [1] and patch set [2].

This client is needed to properly integrate coming RDMAtool [3]
into iproute2 package which is based on netlink.

The following patch set can be logically divided into four parts:
 * Cleanup of RDMA netlink interface to handle dumpit/doit callbacks.
 * Implementation of static ib_device index to allow future renaming support for IB devices.
 * NLDEV initial implementation.
 * Exposing various device ports properties.

Doug,
This series passed extensive review and I would be happy to see this series series merged in
this merge window, so I will be able to focus on more complex types for the "get interface" and
on on "set ability", which is long waited feature for the whole RDMA stack [4].

Thanks

Chagelog:
v1->v2:
 * Groupped all various export* commits into this one patch set.
 * Fixed reversed port vailidy check.
 * Limited export of fields only for supported protocols.
 * Followed sysfs naming for various exported properties.
v0->v1:
 * Added Steve's Reviewed-by tags for all patches except patch #8, because it was completely rewritten.
 * Implemented static indexes for ib_device in patch #8 and dropped preview version which
   translated device name to corresponding ib_device.
 * Fixed language in commit messages as was pointed by Steve.
 * Rename TODO to be FIXME in patch #11.

Thanks

[1] "Revert "IB/core: Add flow control to the portmapper netlink calls""
     https://patchwork.kernel.org/patch/9752865/

[2] [PATCH rdma-next V3 0/5] Refactor RDMA netlink infrastructure
    https://www.spinics.net/lists/linux-rdma/msg51455.html

[3] [RFC iproute2 0/8] RDMA tool
    https://www.spinics.net/lists/linux-rdma/msg49575.html

[4] https://www.spinics.net/lists/linux-rdma/msg51476.html

Available in the "topic/rdma-netlink-v2" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=topic/rdma-netlink-v2

CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Ariel Almog <ariela@mellanox.com>
CC: Linux RDMA <linux-rdma@vger.kernel.org>
CC: Linux Netdev <netdev@vger.kernel.org>

Leon Romanovsky (27):
  RDMA/netlink: Add flag to consolidate common handing
  RDMA/netlink: Simplify the put_msg and put_attr
  RDMA/netlink: Rename and remove redundant parameter from ibnl_unicast
  RDMA/netlink: Rename and remove redundant parameter from
    ibnl_multicast
  RDMA/netlink: Simplify and rename ibnl_chk_listeners
  RDMA/netlink: Rename netlink callback struct
  RDMA/core: Add iterator over ib_devices
  RDMA/core: Add and expose static device index
  RDMA/netlink: Add and implement doit netlink callback
  RDMA/netlink: Reduce indirection access to cb_table
  RDMA/netlink: Convert LS to doit callback
  RDMA/netlink: Update copyright
  RDMA/netlink: Add netlink device definitions to UAPI
  RDMA/netlink: Add nldev initialization flows
  RDMA/netlink: Implement nldev device dumpit calback
  RDMA/netlink: Add nldev device doit implementation
  RDMA/netlink: Add nldev port dumpit implementation
  RDMA/netlink: Implement nldev port doit callback
  RDMA/netlink: Expose device and port capability masks
  RDMA: Simplify get firmware interface
  RDMA/netlink: Export FW version
  RDMA/netlink: Export node_guid and sys_image_guid
  RDMA/netlink: Advertise IB subnet prefix
  RDMA/netink: Export lids and sm_lids
  RDMA/netlink: Export LID mask counter (LMC)
  RDMA/netlink: Provide port state and physical link state
  RDMA/netlink: Export node_type

 drivers/infiniband/core/Makefile               |   4 +-
 drivers/infiniband/core/addr.c                 |  12 +-
 drivers/infiniband/core/cma.c                  |   2 +-
 drivers/infiniband/core/core_priv.h            |  21 +-
 drivers/infiniband/core/device.c               |  82 ++++++-
 drivers/infiniband/core/iwcm.c                 |   2 +-
 drivers/infiniband/core/iwpm_msg.c             |   8 +-
 drivers/infiniband/core/iwpm_util.c            |   4 +-
 drivers/infiniband/core/netlink.c              |  97 ++++----
 drivers/infiniband/core/nldev.c                | 312 +++++++++++++++++++++++++
 drivers/infiniband/core/sa_query.c             |  18 +-
 drivers/infiniband/core/sysfs.c                |   4 +-
 drivers/infiniband/hw/cxgb3/iwch_provider.c    |   5 +-
 drivers/infiniband/hw/cxgb4/provider.c         |   5 +-
 drivers/infiniband/hw/hfi1/verbs.c             |   5 +-
 drivers/infiniband/hw/i40iw/i40iw_verbs.c      |   7 +-
 drivers/infiniband/hw/mlx4/main.c              |   5 +-
 drivers/infiniband/hw/mlx5/main.c              |   8 +-
 drivers/infiniband/hw/mthca/mthca_provider.c   |   5 +-
 drivers/infiniband/hw/nes/nes_verbs.c          |   5 +-
 drivers/infiniband/hw/ocrdma/ocrdma_main.c     |   5 +-
 drivers/infiniband/hw/qedr/main.c              |   5 +-
 drivers/infiniband/hw/usnic/usnic_ib_main.c    |   6 +-
 drivers/infiniband/hw/vmw_pvrdma/pvrdma_main.c |   5 +-
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c   |   3 +-
 include/rdma/ib_verbs.h                        |   8 +-
 include/rdma/rdma_netlink.h                    |  26 ++-
 include/uapi/rdma/rdma_netlink.h               |  84 ++++++-
 28 files changed, 611 insertions(+), 142 deletions(-)
 create mode 100644 drivers/infiniband/core/nldev.c
