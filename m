From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 00/10] IB SR-IOV support
Date: Tue,  1 Mar 2016 18:52:13 +0200
Message-ID: <1456851143-138332-1-git-send-email-eli@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Doug, Dave 

The following series adds support for managing SRIOV IB VFs in a standard 
way (rtnetlink, iproute2) through IPoIB ndo entries which translate to 
corresponding verbs calls. 

In IB networks, 64 bit GUIDs are used as the primary means of identification. 
To support that for VFs, we added a set_vf_guid ndo which is used to program 
the VF node and port GUID from the PF. 

Those verbs are implemented by the mlx5 driver along with some more changes 
needed in the driver, IPoIB and the IB core to support IB virtualization.

We've copied netdev only on the 1st patch of the series, as the rest of it just 
uses the patch along with the existing ndos in IPoIB plus add things which 
are internal to the IB stack. 

The series is rebased against 4.5-rc6 and Meny's patches:
http://www.spinics.net/lists/linux-rdma/msg33536.html and also assumes
Leon's patch that extends the kernel ib device attr caps field to u64.

Eli 

Eli Cohen (9):
  net/core: Add support for configuring VF GUIDs
  IB/mlx5: Fix decision on using MAD_IFC
  IB/core: Support accessing SA in virtualized environment
  IB/core: Add interfaces to control VF attributes
  IB/ipoib: Add ndo operations for configuring VFs
  net/mlx5_core: Add VF param when querying vport counter
  net/mlx5_core: Implement modify HCA vport command
  IB/mlx5: Implement callbacks for manipulating VFs
  IB/ipoib: Allow mcast packets from other VFs

Or Gerlitz (1):
  IB/core: Use GRH when the path hop-limit > 0

 drivers/infiniband/core/device.c                |   1 +
 drivers/infiniband/core/sa_query.c              |   7 +-
 drivers/infiniband/core/verbs.c                 |  40 +++++
 drivers/infiniband/hw/mlx5/Makefile             |   2 +-
 drivers/infiniband/hw/mlx5/ib_virt.c            | 194 ++++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mad.c                |   2 +-
 drivers/infiniband/hw/mlx5/main.c               |  12 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h            |   8 +
 drivers/infiniband/ulp/ipoib/ipoib_ib.c         |  29 +++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c       |  65 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c   |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.c |  72 ++++++++-
 include/linux/mlx5/driver.h                     |   5 +-
 include/linux/mlx5/mlx5_ifc.h                   |   6 +
 include/linux/mlx5/vport.h                      |   7 +-
 include/linux/netdevice.h                       |   3 +
 include/rdma/ib_verbs.h                         |  25 +++
 include/uapi/linux/if_link.h                    |   7 +
 net/core/rtnetlink.c                            |  79 +++++++++-
 19 files changed, 547 insertions(+), 23 deletions(-)
 create mode 100644 drivers/infiniband/hw/mlx5/ib_virt.c

-- 
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
