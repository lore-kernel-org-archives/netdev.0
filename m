From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 00/14] QLogic VNIC Driver
Date: Tue, 10 Jun 2008 17:02:14 -0400
Message-ID: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
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

This is the fourth round of QLogic Virtual NIC driver patch series for submission
to 2.6.27 kernel. The series has been tested against your for-2.6.27 branch.

Based on comments received on third series of patches, following fixes have
been introduced in this series:

	-  Single value per sysfs file created by QLogic VNIC Driver.
	-  Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic
	   describing the sysfs interface of the QLogic VNIC Driver.
	-  Use of existing dev->stats instead of driver's private
	   vnic->stats.
    -  Changing more generic name completion_callback_cleanup to
	   the one more driver specific - vnic_completion_cleanup
    -  Removal of the field vnic->open
    -  Minor Modifications to linked list manipulations.

The sparse endianness checking for the driver did not give any warnings and
checkpatch.pl have few warnings indicating lines slightly longer than 80 columns.

Background:
As mentioned in the earlier versions of patch series, this series adds QLogic
Virtual NIC (VNIC) driver which works in conjunction with the the QLogic
Ethernet Virtual I/O Controller (EVIC) hardware. The VNIC driver along with the
QLogic EVIC's two 10 Gigabit ethernet ports, enables Infiniband clusters to
connect to Ethernet networks. This driver also works with the earlier version of
the I/O Controller, the VEx.

The QLogic VNIC driver creates virtual ethernet interfaces and tunnels the
Ethernet data to/from the EVIC over Infiniband using an Infiniband reliable
connection.

	[PATCH v4 01/14] QLogic VNIC: Driver - netdev implementation.
	[PATCH v4 02/14] QLogic VNIC: Netpath - abstraction of connection to EVIC/VEx.
	[PATCH v4 03/14] QLogic VNIC: Implementation of communication protocol with EVIC/VEx.
	[PATCH v4 04/14] QLogic VNIC: Implementation of Control path of communication protocol.
	[PATCH v4 05/14] QLogic VNIC: Implementation of Data path of communication protocol.
	[PATCH v4 06/14] QLogic VNIC: IB core stack interaction.
	[PATCH v4 07/14] QLogic VNIC: Handling configurable parameters of the driver.
	[PATCH v4 08/14] QLogic VNIC: sysfs interface implementation for the driver.
	[PATCH v4 09/14] QLogic VNIC: IB Multicast for Ethernet broadcast/multicast.
	[PATCH v4 10/14] QLogic VNIC: Driver Statistics collection.
	[PATCH v4 11/14] QLogic VNIC: Driver utility file - implements various utility macros.
	[PATCH v4 12/14] QLogic VNIC: Driver Kconfig and Makefile.
	[PATCH v4 13/14] QLogic VNIC: Modifications to IB Kconfig and Makefile.
	[PATCH v4 14/14] QLogic VNIC: sysfs Documentation.

 .../ABI/testing/sysfs-class-infiniband-qlgc-vnic   |  179 ++
 drivers/infiniband/Kconfig                         |    2 
 drivers/infiniband/Makefile                        |    1 
 drivers/infiniband/ulp/qlgc_vnic/Kconfig           |   19 
 drivers/infiniband/ulp/qlgc_vnic/Makefile          |   13 
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.c     |  379 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_config.h     |  240 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.c    | 2286 ++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_control.h    |  180 ++
 .../infiniband/ulp/qlgc_vnic/vnic_control_pkt.h    |  368 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.c       | 1492 +++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_data.h       |  206 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.c         | 1057 +++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_ib.h         |  207 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.c       | 1097 ++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_main.h       |  159 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c  |  319 +++
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h  |   77 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c    |  109 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h    |   80 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.c      |  234 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_stats.h      |  497 ++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.c        | 1256 +++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_sys.h        |   52 
 drivers/infiniband/ulp/qlgc_vnic/vnic_trailer.h    |  103 +
 drivers/infiniband/ulp/qlgc_vnic/vnic_util.h       |  236 ++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.c     | 1214 +++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_viport.h     |  175 ++
 28 files changed, 12237 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic
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
