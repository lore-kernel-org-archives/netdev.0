From: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Mon, 21 Dec 2015 17:13:00 -0600
Message-ID: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This (V1) series contains the addition of the i40iw.ko driver after
incorporating the feedback from Christoph Hellwig and Joe Perches for
initial series.

This driver provides iWARP RDMA functionality for the Intel(R) X722 Ethernet
controller for PCI Physical Functions. It also has support for Virtual
Function driver (i40iwvf.ko), which that will be part of separate patch
series.

It cooperates with the Intel(R) X722 base driver (i40e.ko) to allocate
resources and program the controller.

This series include 1 patch to i40e.ko to provide interface support to
i40iw.ko. The interface provides a driver registration mechanism, resource
allocations, and device reset coordination mechanisms.

This patch series is based on Doug Ledford's k.o/for-4.5.


Anjali Singhai Jain (1)
net/ethernet/intel/i40e: Add support for client interface for IWARP driver

Faisal Latif(15):
infiniband/hw/i40iw: add main, hdr, status
infiniband/hw/i40iw: add connection management code
infiniband/hw/i40iw: add puda code
infiniband/hw/i40iw: add pble resource files
infiniband/hw/i40iw: add hmc resource files
infiniband/hw/i40iw: add hw and utils files
infiniband/hw/i40iw: add files for iwarp interface
infiniband/hw/i40iw: add file to handle cqp calls
infiniband/hw/i40iw: add hardware related header files
infiniband/hw/i40iw: add X722 register file
infiniband/hw/i40iw: user kernel shared files
infiniband/hw/i40iw: virtual channel handling files
infiniband/hw/i40iw: Kconfig and Kbuild for iwarp module
infiniband/hw/i40iw: Add entry for I40IW rdma_netlink.h
infiniband/hw/i40iw: changes for build of i40iw module

Changes done from initial version to V1 are following.

Feedback received from Christoph Hellwig
*Remove pointless braces -improved after code review and changing
*kmap()/kunmap() - made it very short lived
*less casts -improved 
*Remove unused routine stubs - done
*no initialize to 0 or NULL when struct field were zeroed - done
*define UNREFERENCED_PARAMETER not needed -done
*remove define I40eE_MASK  -done
*rd32(), wr32() make them inline -done
*readq() use magic in linux/io-64-nonatomic-lo-hi.h -done
*SLEEP() define -done by removing it
*entry in rdma_netlink.h for I40IW should be in proper location
	and separate patch -done

Feedback received from Joe Perches
*series to respuun re-spun against next - done with
	Doug's Ledford's k.o/for-4.5
*Change to i40e client patch regarding mailing list - this is consistent
	with other i40e files.
*Removed error from i40iw_pr_err() -done
*cqp_request() change from bitfields to bool -done
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
