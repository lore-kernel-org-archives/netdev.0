From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next 00/19] RDMA Netlink Device Client
Date: Wed, 21 Jun 2017 09:05:09 +0300
Message-ID: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following patch set is an implementation of NLDEV - RDMA netlink
device client. It is based on the already sent patch [1] and patch set [2].

This client is needed to properly integrate coming RDMAtool [3]
into iproute2 package which is based on netlink.

The following patch set can be logically divided into three parts:
 * Cleanup of RDMA netlink interface to handle dumpit/doit callbacks.
 * NLDEV initial implementation
 * Exposing device and capability masks via this interface

The supplementary user space part will follow later or.

Thanks

[1] "Revert "IB/core: Add flow control to the portmapper netlink calls""
     https://patchwork.kernel.org/patch/9752865/

[2] [PATCH rdma-next V2 0/5] Refactor RDMA netlink infrastructure
    https://www.spinics.net/lists/linux-rdma/msg50945.html

[3] [RFC iproute2 0/8] RDMA tool
    https://www.spinics.net/lists/linux-rdma/msg49575.html

Available in the "topic/rdma-netlink" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=topic/rdma-netlink

CC: Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
CC: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
CC: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
CC: Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
CC: Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
CC: Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
CC: Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

Leon Romanovsky (19):
  RDMA/netlink: Add flag to consolidate common handing
  RDMA/netlink: Simplify the put_msg and put_attr
  RDMA/netlink: Rename and remove redundant parameter from ibnl_unicast
  RDMA/netlink: Rename and remove redundant parameter from
    ibnl_multicast
  RDMA/netlink: Simplify and rename ibnl_chk_listeners
  RDMA/netlink: Rename netlink callback struct
  RDMA/core: Add iterator over ib_devices
  RDMA/core: Expose translation from device name to ib_device
  RDMA/netlink: Add and implement doit netlink callback
  RDMA/netlink: Reduce indirection access to cb_table
  RDMA/netlink: Convert LS to doit callback
  RDMA/netlink: Update copyright
  RDMA/netlink: Add netlink device definitions to UAPI
  RDMA/netlink: Add nldev initialization flows
  RDMA/netlink: Implement nldev device dumpit calback
  RDMa/netlink: Add nldev device doit implementation
  RDMA/netlink: Add nldev port dumpit implementation
  RDMA/netlink: Implement nldev port doit callback
  RDMA/netlink: Expose device and port capability masks

 drivers/infiniband/core/Makefile    |   4 +-
 drivers/infiniband/core/addr.c      |  12 +-
 drivers/infiniband/core/cma.c       |   2 +-
 drivers/infiniband/core/core_priv.h |  22 ++-
 drivers/infiniband/core/device.c    |  44 +++++-
 drivers/infiniband/core/iwcm.c      |   2 +-
 drivers/infiniband/core/iwpm_msg.c  |   8 +-
 drivers/infiniband/core/iwpm_util.c |   4 +-
 drivers/infiniband/core/netlink.c   |  98 ++++++-------
 drivers/infiniband/core/nldev.c     | 268 ++++++++++++++++++++++++++++++++++++
 drivers/infiniband/core/sa_query.c  |  18 ++-
 include/rdma/rdma_netlink.h         |  22 +--
 include/uapi/rdma/rdma_netlink.h    |  47 +++++++
 13 files changed, 454 insertions(+), 97 deletions(-)
 create mode 100644 drivers/infiniband/core/nldev.c

--
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
