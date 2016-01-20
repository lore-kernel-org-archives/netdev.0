From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 00/16] add Intel X722 iWARP driver
Date: Wed, 20 Jan 2016 13:40:00 -0600
Message-ID: <1453318816-21672-1-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This driver provides iWARP RDMA functionality for the Intel(R) X722 Ethernet
controller for PCI Physical Functions. It is in early product cycle
and having the driver in the kernel will allow users to have hardware support
when available for purchase.


i40iw cooperates with the Intel(R) X722 base driver (i40e.ko) to allocate
resources and program the controller.

It has support for Virtual Function driver (i40iwvf.ko), which will
be part of separate patch series. The VF driver (i40iwvf) requires i40iw 
for resource management.


This series include 1 patch to i40e.ko to provide interface support to
i40iw.ko. The interface provides a driver registration mechanism, resource
allocations, and device reset coordination mechanisms.


This patch series is based on Doug Ledford's k.o/for-4.5.

Changes since v2:

	Incorporated following comments from Or Gerlitz
		*full git cover letter 
		*0-day testing complete
		*remove unused memtypes
		*move netlink patch up

	Changes made as part of 4.5 merge
		*ported interface changes done for infiniband interface for 4.5
		*some changes made by Christoph Hellwig in nes were also
		 ported to i40iw

	copyright changed to 2015-2016
	moved from Kbuild to Makefile
	Added i40e param change
	fixes including crash during unload


Changes since v1:

	Following review comments from Joe Perches are implemented.
		*No need to print error for i40e_print errpr )
		*Change from bits in cqp to bool in i40iw_cqp_request()

	Following review comments from Christoph Hellwig are implemented.
		*move down the I40IW enum
		*remove pointless braces (all over the code)
		*change usage of kmap() to make it short lived.
		*remove unnecessary casts
		*remove routine stubs
		*do not set unused fields to zero as those are already zero

Anjali Singhai Jain (1):
  i40e: Add support for client interface for IWARP driver

Faisal Latif (15):
  i40iw: add entry in rdma_netlink
  i40iw: add main, hdr, status
  i40iw: add connection management code
  i40iw: add puda code
  i40iw: add pble resource files
  i40iw: add hmc resource files
  i40iw: add hw and utils files
  i40iw: add files for iwarp interface
  i40iw: add file to handle cqp calls
  i40iw: add hardware related header files
  i40iw: add X722 register file
  i40iw: user kernel shared files
  i40iw: virtual channel handling files
  i40iw: Kconfig and Makefile for iwarp module
  i40iw: changes for build of i40iw module

 MAINTAINERS                                        |   10 +
 drivers/infiniband/Kconfig                         |    1 +
 drivers/infiniband/hw/Makefile                     |    1 +
 drivers/infiniband/hw/i40iw/Kconfig                |    7 +
 drivers/infiniband/hw/i40iw/Makefile               |    9 +
 drivers/infiniband/hw/i40iw/i40iw.h                |  569 +++
 drivers/infiniband/hw/i40iw/i40iw_cm.c             | 4442 ++++++++++++++++++
 drivers/infiniband/hw/i40iw/i40iw_cm.h             |  456 ++
 drivers/infiniband/hw/i40iw/i40iw_ctrl.c           | 4743 ++++++++++++++++++++
 drivers/infiniband/hw/i40iw/i40iw_d.h              | 1713 +++++++
 drivers/infiniband/hw/i40iw/i40iw_hmc.c            |  821 ++++
 drivers/infiniband/hw/i40iw/i40iw_hmc.h            |  241 +
 drivers/infiniband/hw/i40iw/i40iw_hw.c             |  730 +++
 drivers/infiniband/hw/i40iw/i40iw_main.c           | 1930 ++++++++
 drivers/infiniband/hw/i40iw/i40iw_osdep.h          |  214 +
 drivers/infiniband/hw/i40iw/i40iw_p.h              |  106 +
 drivers/infiniband/hw/i40iw/i40iw_pble.c           |  618 +++
 drivers/infiniband/hw/i40iw/i40iw_pble.h           |  131 +
 drivers/infiniband/hw/i40iw/i40iw_puda.c           | 1436 ++++++
 drivers/infiniband/hw/i40iw/i40iw_puda.h           |  183 +
 drivers/infiniband/hw/i40iw/i40iw_register.h       | 1030 +++++
 drivers/infiniband/hw/i40iw/i40iw_status.h         |  100 +
 drivers/infiniband/hw/i40iw/i40iw_type.h           | 1312 ++++++
 drivers/infiniband/hw/i40iw/i40iw_ucontext.h       |  107 +
 drivers/infiniband/hw/i40iw/i40iw_uk.c             | 1204 +++++
 drivers/infiniband/hw/i40iw/i40iw_user.h           |  442 ++
 drivers/infiniband/hw/i40iw/i40iw_utils.c          | 1256 ++++++
 drivers/infiniband/hw/i40iw/i40iw_verbs.c          | 2434 ++++++++++
 drivers/infiniband/hw/i40iw/i40iw_verbs.h          |  173 +
 drivers/infiniband/hw/i40iw/i40iw_vf.c             |   85 +
 drivers/infiniband/hw/i40iw/i40iw_vf.h             |   62 +
 drivers/infiniband/hw/i40iw/i40iw_virtchnl.c       |  748 +++
 drivers/infiniband/hw/i40iw/i40iw_virtchnl.h       |  124 +
 drivers/net/ethernet/intel/i40e/Makefile           |    1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   22 +
 drivers/net/ethernet/intel/i40e/i40e_client.c      | 1012 +++++
 drivers/net/ethernet/intel/i40e/i40e_client.h      |  232 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  115 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   34 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  247 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |    4 +
 include/uapi/rdma/rdma_netlink.h                   |    1 +
 43 files changed, 29096 insertions(+), 13 deletions(-)
 create mode 100644 drivers/infiniband/hw/i40iw/Kconfig
 create mode 100644 drivers/infiniband/hw/i40iw/Makefile
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_cm.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_cm.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_ctrl.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_d.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_hmc.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_hmc.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_hw.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_main.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_osdep.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_p.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_pble.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_pble.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_puda.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_puda.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_register.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_status.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_type.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_ucontext.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_uk.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_user.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_utils.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_verbs.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_verbs.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_vf.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_vf.h
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_virtchnl.c
 create mode 100644 drivers/infiniband/hw/i40iw/i40iw_virtchnl.h
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_client.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_client.h

-- 
2.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
