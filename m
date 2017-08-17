From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V6 00/21] Huawei HiNIC Ethernet Driver
Date: Thu, 17 Aug 2017 20:25:08 +0800
Message-ID: <cover.1502972068.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch-set contains the support of the HiNIC Ethernet driver for
hinic family of PCIE Network Interface Cards.

The Huawei's PCIE HiNIC card is a new Ethernet card and hence there was
a need of a new driver.

The current driver is meant to be used for the Physical Function and there
would soon be a support for Virtual Function and more features once the
basic PF driver has been accepted.

Changes V5 -> V6:
1. Fix cover letter Message-Id 

Changes V4 -> V5:
1. Remove select_queue NOP - David Miller comment
        https://lkml.org/lkml/2017/8/16/625

Changes V3 -> V4:
1. Reverse christmas tree order - David Miller comment
        https://lkml.org/lkml/2017/8/3/862

Changes V2 -> V3:
1. Replace dev_ functions by netif_ functions - Joe Perches comment
        https://lkml.org/lkml/2017/7/19/424
2. Fix the driver directory in MAINTAINERS file - Sergei Shtylyov comment
        https://lkml.org/lkml/2017/7/19/615
3. Add a newline at the end of Makefile - David Miller comment
        https://lkml.org/lkml/2017/7/19/1345
4. Return a pointer as a val instead of in arg - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
5. Change the error labels to err_xyz - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
6. Remove check of Func Type in free function - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
7. Remove !netdev check in remove function - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
8. Use module_pci_driver - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
9. Move the PCI device ID to the .c file - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319
10. Remove void * to avoid passing wrong ptr - Francois Romieu comment
        https://lkml.org/lkml/2017/7/19/1319

Changes V1 -> V2:
1. remove driver verstion - Andrew Lunn comment
        https://lkml.org/lkml/2017/7/12/372
2. replace kzalloc by devm_kzalloc for short clean - Andrew Lunn comment
        https://lkml.org/lkml/2017/7/12/372
3. replace pr_ functions by dev_ functions - Andrew Lunn comment
        https://lkml.org/lkml/2017/7/12/375
4. seperate last patch by moving ops to a new patch - Andrew Lunn comment
        https://lkml.org/lkml/2017/7/12/377

Aviad Krawczyk (21):
  net-next/hinic: Initialize hw interface
  net-next/hinic: Initialize hw device components
  net-next/hinic: Initialize api cmd resources
  net-next/hinic: Initialize api cmd hw
  net-next/hinic: Add management messages
  net-next/hinic: Add api cmd commands
  net-next/hinic: Add aeqs
  net-next/hinic: Add port management commands
  net-next/hinic: Add Rx mode and link event handler
  net-next/hinic: Add logical Txq and Rxq
  net-next/hinic: Add wq
  net-next/hinic: Add qp resources
  net-next/hinic: Set qp context
  net-next/hinic: Initialize cmdq
  net-next/hinic: Add ceqs
  net-next/hinic: Add cmdq commands
  net-next/hinic: Add cmdq completion handler
  net-next/hinic: Add Rx handler
  net-next/hinic: Add Tx operation
  net-next/hinic: Add ethtool and stats
  net-next/hinic: Add netpoll

 Documentation/networking/hinic.txt                 |  125 +++
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/huawei/Kconfig                |   19 +
 drivers/net/ethernet/huawei/Makefile               |    5 +
 drivers/net/ethernet/huawei/hinic/Kconfig          |   13 +
 drivers/net/ethernet/huawei/hinic/Makefile         |    6 +
 drivers/net/ethernet/huawei/hinic/hinic_common.c   |   80 ++
 drivers/net/ethernet/huawei/hinic/hinic_common.h   |   38 +
 drivers/net/ethernet/huawei/hinic/hinic_dev.h      |   64 ++
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.c   |  977 +++++++++++++++++
 .../net/ethernet/huawei/hinic/hinic_hw_api_cmd.h   |  208 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c  |  946 +++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h  |  187 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h   |  149 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c   | 1045 ++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h   |  239 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c   |  888 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h   |  265 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c    |  352 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h    |  272 +++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c    |  533 ++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h    |   97 ++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c  |  597 +++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h  |  153 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c    |  892 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h    |  180 ++++
 .../net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h   |  214 ++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c    |  879 ++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h    |  117 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h   |  368 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_main.c     | 1111 ++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.c     |  379 +++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h     |  198 ++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.c       |  510 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_rx.h       |   55 +
 drivers/net/ethernet/huawei/hinic/hinic_tx.c       |  503 +++++++++
 drivers/net/ethernet/huawei/hinic/hinic_tx.h       |   62 ++
 39 files changed, 12735 insertions(+)
 create mode 100644 Documentation/networking/hinic.txt
 create mode 100644 drivers/net/ethernet/huawei/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/Kconfig
 create mode 100644 drivers/net/ethernet/huawei/hinic/Makefile
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_common.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_api_cmd.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_cmdq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_csr.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_eqs.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_if.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_io.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_mgmt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_qp_ctxt.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wq.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_hw_wqe.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_main.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_rx.h
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_tx.h

-- 
1.9.1
