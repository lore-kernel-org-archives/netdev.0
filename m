From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [V5 PATCH 0/8] csiostor: Chelsio FCoE offload driver submission
Date: Mon, 8 Oct 2012 15:37:01 +0530
Message-ID: <5072A5C5.6070102@chelsio.com>
References: <1348507072-25625-1-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Naresh Kumar Inna <naresh@chelsio.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: "JBottomley@parallels.com" <JBottomley@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11467 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab2JHKHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 06:07:14 -0400
In-Reply-To: <1348507072-25625-1-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi James,

Please let me know if you are expecting any more changes to this driver
to resume its review. I have addressed all review comments as of the
last series of patches (below).

Thanks,
Naresh.

On 9/24/2012 10:47 PM, Naresh Kumar Inna wrote:
> This is the initial submission of the Chelsio FCoE offload driver (csiostor)
> to the upstream kernel. This driver currently supports FCoE offload
> functionality over Chelsio T4-based 10Gb Converged Network Adapters.
> 
> The following patches contain the driver sources for csiostor driver and
> updates to firmware/hardware header files shared between csiostor,
> cxgb4 (Chelsio T4-based NIC driver) and cxgb4vf (Chelsio T4-based Virtual
> Function NIC driver). The csiostor driver is dependent on these
> header updates. These patches have been generated against scsi 'misc' branch.
> 
> csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
> FC transport subsystems. This driver claims the FCoE PCIe function on
> Chelsio Converged Network Adapters. It relies on firmware events for slow path
> operations like discovery, thereby offloading session management. The driver
> programs firmware via Work Request interfaces for fast path I/O offload
> features.
> 
> Version V5 of the patches addresses James's comment, primary among them being
> moving to the lockless version of queuecommand(). Rest of the V5 changes are
> listed in the individual patches.
> 
> Here is the brief description of patches:
> [V5 PATCH 1/8]: Updates to header files shared between cxgb4, cxgb4vf and
>                 csiostor.
> [V5 PATCH 2/8]: Header files part 1.
> [V5 PATCH 3/8]: Header files part 2.
> [V5 PATCH 4/8]: Driver initialization and Work Request services.
> [V5 PATCH 5/8]: FC transport interfaces and mailbox services.
> [V5 PATCH 6/8]: Local and remote port state tracking functionality.
> [V5 PATCH 7/8]: Interrupt handling and fast path I/O functionality.
> [V5 PATCH 8/8]: Hardware interface, Makefile and Kconfig changes.
> 
> Naresh Kumar Inna (8):
>   cxgb4/cxgb4vf: Chelsio FCoE offload driver submission (common header
>     updates).
>   csiostor: Chelsio FCoE offload driver submission (headers part 1).
>   csiostor: Chelsio FCoE offload driver submission (headers part 2).
>   csiostor: Chelsio FCoE offload driver submission (sources part 1).
>   csiostor: Chelsio FCoE offload driver submission (sources part 2).
>   csiostor: Chelsio FCoE offload driver submission (sources part 3).
>   csiostor: Chelsio FCoE offload driver submission (sources part 4).
>   csiostor: Chelsio FCoE offload driver submission (sources part 5).
> 
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |   10 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   16 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   69 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  104 +-
>  drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |   11 +-
>  drivers/scsi/Kconfig                            |    1 +
>  drivers/scsi/Makefile                           |    1 +
>  drivers/scsi/csiostor/Kconfig                   |   19 +
>  drivers/scsi/csiostor/Makefile                  |   11 +
>  drivers/scsi/csiostor/csio_attr.c               |  804 +++++
>  drivers/scsi/csiostor/csio_defs.h               |  121 +
>  drivers/scsi/csiostor/csio_hw.c                 | 4395 +++++++++++++++++++++++
>  drivers/scsi/csiostor/csio_hw.h                 |  666 ++++
>  drivers/scsi/csiostor/csio_init.c               | 1274 +++++++
>  drivers/scsi/csiostor/csio_init.h               |  158 +
>  drivers/scsi/csiostor/csio_isr.c                |  624 ++++
>  drivers/scsi/csiostor/csio_lnode.c              | 2133 +++++++++++
>  drivers/scsi/csiostor/csio_lnode.h              |  255 ++
>  drivers/scsi/csiostor/csio_mb.c                 | 1769 +++++++++
>  drivers/scsi/csiostor/csio_mb.h                 |  278 ++
>  drivers/scsi/csiostor/csio_rnode.c              |  889 +++++
>  drivers/scsi/csiostor/csio_rnode.h              |  141 +
>  drivers/scsi/csiostor/csio_scsi.c               | 2554 +++++++++++++
>  drivers/scsi/csiostor/csio_scsi.h               |  342 ++
>  drivers/scsi/csiostor/csio_wr.c                 | 1632 +++++++++
>  drivers/scsi/csiostor/csio_wr.h                 |  512 +++
>  drivers/scsi/csiostor/t4fw_api_stor.h           |  578 +++
>  29 files changed, 19333 insertions(+), 37 deletions(-)
>  create mode 100644 drivers/scsi/csiostor/Kconfig
>  create mode 100644 drivers/scsi/csiostor/Makefile
>  create mode 100644 drivers/scsi/csiostor/csio_attr.c
>  create mode 100644 drivers/scsi/csiostor/csio_defs.h
>  create mode 100644 drivers/scsi/csiostor/csio_hw.c
>  create mode 100644 drivers/scsi/csiostor/csio_hw.h
>  create mode 100644 drivers/scsi/csiostor/csio_init.c
>  create mode 100644 drivers/scsi/csiostor/csio_init.h
>  create mode 100644 drivers/scsi/csiostor/csio_isr.c
>  create mode 100644 drivers/scsi/csiostor/csio_lnode.c
>  create mode 100644 drivers/scsi/csiostor/csio_lnode.h
>  create mode 100644 drivers/scsi/csiostor/csio_mb.c
>  create mode 100644 drivers/scsi/csiostor/csio_mb.h
>  create mode 100644 drivers/scsi/csiostor/csio_rnode.c
>  create mode 100644 drivers/scsi/csiostor/csio_rnode.h
>  create mode 100644 drivers/scsi/csiostor/csio_scsi.c
>  create mode 100644 drivers/scsi/csiostor/csio_scsi.h
>  create mode 100644 drivers/scsi/csiostor/csio_wr.c
>  create mode 100644 drivers/scsi/csiostor/csio_wr.h
>  create mode 100644 drivers/scsi/csiostor/t4fw_api_stor.h
> 
