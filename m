From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH 00/13] QLogic Virtual NIC (VNIC) Driver
Date: Wed, 30 Apr 2008 22:45:52 +0530
Message-ID: <20080430171028.31725.86190.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland,

This is the QLogic Virtual NIC driver patch series which has been tested
against your for-2.6.26 and for-2.6.27 branches. We intended these patches to
make it to the 2.6.26 kernel, but if it is too late for the 2.6.26 merge window
please consider them for 2.6.27.

This patch series adds the QLogic Virtual NIC (VNIC) driver which works in
conjunction with the the QLogic Ethernet Virtual I/O Controller (EVIC) hardware.
The VNIC driver along with the QLogic EVIC's two 10 Gigabit ethernet ports,
enables Infiniband clusters to connect to Ethernet networks. This driver also
works with the earlier version of the I/O Controller, the VEx.

The QLogic VNIC driver creates virtual ethernet interfaces and tunnels the
Ethernet data to/from the EVIC over Infiniband using an Infiniband reliable
connection.

The driver compiles cleanly with sparse endianness checking enabled. We have
also tested the driver with lockdep checking enabled.

We have run these patches through checkpatch.pl and the only warnings are
related to lines slightly longer than 80 columns in some of the statements.

The driver itself has has been tested with long duration iperf, netperf TCP,
UDP streams.

---

      [PATCH 01/13] QLogic VNIC: Driver - netdev implementation
      [PATCH 02/13] QLogic VNIC: Netpath - abstraction of connection to EVIC/VEx
      [PATCH 03/13] QLogic VNIC: Implementation of communication protocol with EVIC/VEx
      [PATCH 04/13] QLogic VNIC: Implementation of Control path of communication protocol
      [PATCH 05/13] QLogic VNIC: Implementation of Data path of communication protocol
      [PATCH 06/13] QLogic VNIC: IB core stack interaction
      [PATCH 07/13] QLogic VNIC: Handling configurable parameters of the driver
      [PATCH 08/13] QLogic VNIC: sysfs interface implementation for the driver
      [PATCH 09/13] QLogic VNIC: IB Multicast for Ethernet broadcast/multicast
      [PATCH 10/13] QLogic VNIC: Driver Statistics collection
      [PATCH 11/13] QLogic VNIC: Driver utility file - implements various utility macros
      [PATCH 12/13] QLogic VNIC: Driver Kconfig and Makefile.
      [PATCH 13/13] QLogic VNIC: Modifications to IB Kconfig and Makefile


 drivers/infiniband/Kconfig                         |    2 
 drivers/infiniband/Makefile                        |    1 
 drivers/infiniband/ulp/qlgc_vnic/Kconfig           |   28 
 drivers/infiniband/ulp/qlgc_vnic/Makefile          |   13 
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c     |  380 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h     |  242 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c    | 2288 ++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h    |  180 ++
 .../infiniband/ulp/qlgc_vnic/vnic_control_pkt.h    |  368 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c       | 1473 +++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h       |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c         | 1046 +++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h         |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c       | 1052 +++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h       |  167 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c  |  332 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h  |   76 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c    |  112 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h    |   80 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c      |  234 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h      |  497 ++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c        | 1127 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h        |   62 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h    |  103 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h       |  251 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c     | 1233 +++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h     |  176 ++
 27 files changed, 11935 insertions(+), 0 deletions(-)
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
