From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [PATCH v3 00/13] QLogic VNIC Driver
Date: Thu, 29 May 2008 15:23:46 +0530
Message-ID: <20080529095126.9943.84692.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from altair.gslab.com ([221.135.187.70]:48971 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752523AbYE2Qu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 12:50:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland,

This is the third round of QLogic Virtual NIC driver patch series for submission
to 2.6.27 kernel. The series has been tested against your for-2.6.27 branch.

Based on comments received on second series of patches, following fixes are
introduced in this series:

        -  Removal of CONFIG_INFINIBAND_QLGC_VNIC_DEBUG option.
        -  Making few function definitions static.
        -  Removed un-necessary extern declarations.

The sparse endianness checking for the driver did not give any warnings and
checkpatch.pl have few warnings indicating lines slightly longer than 80 columns.

Background:
As mentioned in the first version of patch series, this series adds QLogic
Virtual NIC (VNIC) driver which works in conjunction with the the QLogic
Ethernet Virtual I/O Controller (EVIC) hardware. The VNIC driver along with the
QLogic EVIC's two 10 Gigabit ethernet ports, enables Infiniband clusters to
connect to Ethernet networks. This driver also works with the earlier version of
the I/O Controller, the VEx.

The QLogic VNIC driver creates virtual ethernet interfaces and tunnels the
Ethernet data to/from the EVIC over Infiniband using an Infiniband reliable
connection.

      [PATCH v3 01/13] QLogic VNIC: Driver - netdev implementation
      [PATCH v3 02/13] QLogic VNIC: Netpath - abstraction of connection to EVIC/VEx
      [PATCH v3 03/13] QLogic VNIC: Implementation of communication protocol with EVIC/VEx
      [PATCH v3 04/13] QLogic VNIC: Implementation of Control path of communication protocol
      [PATCH v3 05/13] QLogic VNIC: Implementation of Data path of communication protocol
      [PATCH v3 06/13] QLogic VNIC: IB core stack interaction
      [PATCH v3 07/13] QLogic VNIC: Handling configurable parameters of the driver
      [PATCH v3 08/13] QLogic VNIC: sysfs interface implementation for the driver
      [PATCH v3 09/13] QLogic VNIC: IB Multicast for Ethernet broadcast/multicast
      [PATCH v3 10/13] QLogic VNIC: Driver Statistics collection
      [PATCH v3 11/13] QLogic VNIC: Driver utility file - implements various utility macros
      [PATCH v3 12/13] QLogic VNIC: Driver Kconfig and Makefile.
      [PATCH v3 13/13] QLogic VNIC: Modifications to IB Kconfig and Makefile

 drivers/infiniband/Kconfig                         |    2 
 drivers/infiniband/Makefile                        |    1 
 drivers/infiniband/ulp/qlgc_vnic/Kconfig           |   19 
 drivers/infiniband/ulp/qlgc_vnic/Makefile          |   13 
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c     |  379 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h     |  242 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c    | 2286 ++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h    |  179 ++
 .../infiniband/ulp/qlgc_vnic/vnic_control_pkt.h    |  368 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c       | 1492 +++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h       |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c         | 1043 +++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h         |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c       | 1098 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h       |  154 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c  |  319 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h  |   77 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c    |  112 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h    |   79 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c      |  234 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h      |  497 ++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c        | 1133 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h        |   51 
 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h    |  103 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h       |  236 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c     | 1214 +++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h     |  175 ++
 27 files changed, 11918 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Kconfig
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/Makefile
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_control_pkt.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h

--
Regards,
Ram 
