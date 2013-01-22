From: sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Subject: [PATCH v4 0/9] rdma/cm: Add support for native Infiniband addressing
Date: Tue, 22 Jan 2013 13:56:28 -0800
Message-ID: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This is the first group of patches in a series that adds the
ability to handle native Infiniband addressing to the rdma_cm.
I'm breaking the submission up to limit the number of patches
that need to be reviewed at once, hoping that this helps with
merging the code upstream.  The full patch series is available
from:

        git://git.openfabrics.org/~shefty/rdma-dev.git for-next

Allowing the use of native IB addresses removes the requirement
for IPoIB, which in turn allows us to offload name and/or address
translation services to a user space daemon.  The primary motivation
is to support large scale fabrics, with address and name services
either cached or bypassed completely.  For example, IB GIDs are
known or the information is exchanged out of band by an MPI process
manager.  However, another use case involves load balancing software.
Currently the rdma cm cannot establish rdma connections through
a load balancer, since the IP -> GID mapping is not well defined.
An out of band mechanism could be used in such situations to
determine the correct mapping, with the rdma cm still managing
the connection.

The patch set introduces af_ib and sockaddr_ib.  The kernel
rdma_cm is updated accordingly, mainly to make its handling of
addresses more generic.  However, since sockaddr_ib is larger
than sockaddr_in6, the rdma_ucm requires changes to its user to
kernel interface.  To provide backwards compatibility, the userspace
ABI is extended to support the larger address size.

Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Changes from v3:
Updated to 3.8-rc4 kernel

Sean Hefty (9):
  rdma/cm: define native IB address
  rdma/cm: Include AF_IB in loopback and any address checks
  ib/addr: Add AF_IB support to ip_addr_size
  rdma/cm: Update port reservation to support AF_IB
  rdma/cm: Allow user to specify AF_IB when binding
  rdma/cm: Do not modify sa_family when setting loopback address
  rdma/cm: Add helper functions to return id address information
  rdma/cm: Restrict AF_IB loopback to binding to IB devices only
  rdma/cm: Verify that source and dest sa_family are the same

 drivers/infiniband/core/addr.c |   20 ++-
 drivers/infiniband/core/cma.c  |  374 ++++++++++++++++++++++++++--------------
 include/linux/socket.h         |    2 +
 include/rdma/ib.h              |   89 ++++++++++
 include/rdma/ib_addr.h         |    6 +-
 include/rdma/rdma_cm.h         |    5 +
 6 files changed, 359 insertions(+), 137 deletions(-)
 create mode 100644 include/rdma/ib.h

-- 
1.7.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
