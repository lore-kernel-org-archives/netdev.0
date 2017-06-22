From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V1 00/19] RDMA Netlink Device Client
Date: Thu, 22 Jun 2017 16:24:15 +0300
Message-ID: <20170622132434.1327-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60432 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751094AbdFVNYj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 09:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This is second version of the RDMA netlink patch set.

The following patch set is an implementation of NLDEV - RDMA netlink
device client. It is based on the already sent patch [1] and patch set [2].

This client is needed to properly integrate coming RDMAtool [3]
into iproute2 package which is based on netlink.

The following patch set can be logically divided into four parts:
 * Cleanup of RDMA netlink interface to handle dumpit/doit callbacks.
 * Implementation of static ib_device index to allow future renaming support for IB devices.
 * NLDEV initial implementation
 * Exposing device and capability masks via this interface

The supplementary user space part will follow later on.

Chagelog:
v0->v1:
 * Added Steve's Reviewed-by tags for all patches except patch #8, because it was completely rewritten.
 * Implemented static indexes for ib_device in patch #8 and dropped preview version which
   translated device name to corresponding ib_device.
 * Fixed language in commit messages as was pointed by Steve.
 * Rename TODO to be FIXME in patch #11.

Thanks

[1] "Revert "IB/core: Add flow control to the portmapper netlink calls""
     https://patchwork.kernel.org/patch/9752865/

[2] [PATCH rdma-next V2 0/5] Refactor RDMA netlink infrastructure
    https://www.spinics.net/lists/linux-rdma/msg50945.html

[3] [RFC iproute2 0/8] RDMA tool
    https://www.spinics.net/lists/linux-rdma/msg49575.html

Available in the "topic/rdma-netlink-v1" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=topic/rdma-netlink-v1

CC: Chien Tin Tung <chien.tin.tung@intel.com>
CC: Steve Wise <swise@opengridcomputing.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Jiri Pirko <jiri@mellanox.com>
CC: Ariel Almog <ariela@mellanox.com>
CC: Linux RDMA <linux-rdma@vger.kernel.org>
CC: Linux Netdev <netdev@vger.kernel.org>


*** BLURB HERE ***

Leon Romanovsky (19):
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

 drivers/infiniband/core/Makefile    |   4 +-
 drivers/infiniband/core/addr.c      |  12 +-
 drivers/infiniband/core/cma.c       |   2 +-
 drivers/infiniband/core/core_priv.h |  21 ++-
 drivers/infiniband/core/device.c    |  78 ++++++++++-
 drivers/infiniband/core/iwcm.c      |   2 +-
 drivers/infiniband/core/iwpm_msg.c  |   8 +-
 drivers/infiniband/core/iwpm_util.c |   4 +-
 drivers/infiniband/core/netlink.c   |  98 ++++++-------
 drivers/infiniband/core/nldev.c     | 271 ++++++++++++++++++++++++++++++++++++
 drivers/infiniband/core/sa_query.c  |  18 ++-
 include/rdma/ib_verbs.h             |   2 +
 include/rdma/rdma_netlink.h         |  22 +--
 include/uapi/rdma/rdma_netlink.h    |  44 +++++-
 14 files changed, 489 insertions(+), 97 deletions(-)
 create mode 100644 drivers/infiniband/core/nldev.c
