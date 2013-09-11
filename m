From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 00/52] net: ethernet: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:19:33 +0900
Message-ID: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:39494 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab3IKHTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:19:40 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY000LX9OHUPF0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:19:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound),
the driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

---
 drivers/net/ethernet/3com/typhoon.c                  |    1 -
 drivers/net/ethernet/8390/ne2k-pci.c                 |    3 ---
 drivers/net/ethernet/adaptec/starfire.c              |    2 --
 drivers/net/ethernet/amd/amd8111e.c                  |    2 --
 drivers/net/ethernet/amd/pcnet32.c                   |    1 -
 drivers/net/ethernet/atheros/alx/main.c              |    1 -
 drivers/net/ethernet/broadcom/bnx2.c                 |    3 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |    3 ---
 drivers/net/ethernet/broadcom/tg3.c                  |    2 --
 drivers/net/ethernet/brocade/bna/bnad.c              |    1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c            |    2 --
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c      |    2 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    5 ++---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c  |    3 ---
 drivers/net/ethernet/cisco/enic/enic_main.c          |    2 --
 drivers/net/ethernet/dec/tulip/de2104x.c             |    1 -
 drivers/net/ethernet/dec/tulip/dmfe.c                |    3 ---
 drivers/net/ethernet/dec/tulip/tulip_core.c          |    1 -
 drivers/net/ethernet/dec/tulip/uli526x.c             |    2 --
 drivers/net/ethernet/dec/tulip/winbond-840.c         |    3 ---
 drivers/net/ethernet/dec/tulip/xircom_cb.c           |    2 --
 drivers/net/ethernet/dlink/dl2k.c                    |    1 -
 drivers/net/ethernet/dlink/sundance.c                |    2 --
 drivers/net/ethernet/emulex/benet/be_main.c          |    2 --
 drivers/net/ethernet/fealnx.c                        |    4 ++--
 drivers/net/ethernet/icplus/ipg.c                    |    1 -
 drivers/net/ethernet/intel/e100.c                    |    2 --
 drivers/net/ethernet/jme.c                           |    2 --
 drivers/net/ethernet/marvell/skge.c                  |    2 --
 drivers/net/ethernet/marvell/sky2.c                  |    3 ---
 drivers/net/ethernet/micrel/ksz884x.c                |    2 --
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c     |    1 -
 drivers/net/ethernet/natsemi/natsemi.c               |    2 --
 drivers/net/ethernet/neterion/s2io.c                 |    2 --
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |    2 --
 drivers/net/ethernet/packetengines/hamachi.c         |    1 -
 drivers/net/ethernet/packetengines/yellowfin.c       |    2 --
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    1 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 --
 drivers/net/ethernet/qlogic/qla3xxx.c                |    2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    2 --
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    1 -
 drivers/net/ethernet/rdc/r6040.c                     |    2 --
 drivers/net/ethernet/realtek/8139cp.c                |    1 -
 drivers/net/ethernet/realtek/8139too.c               |    1 -
 drivers/net/ethernet/realtek/r8169.c                 |    1 -
 drivers/net/ethernet/sis/sis190.c                    |    1 -
 drivers/net/ethernet/smsc/epic100.c                  |    1 -
 drivers/net/ethernet/smsc/smsc9420.c                 |    2 --
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     |    1 -
 drivers/net/ethernet/sun/cassini.c                   |    2 --
 drivers/net/ethernet/sun/niu.c                       |    2 --
 drivers/net/ethernet/sun/sungem.c                    |    2 --
 drivers/net/ethernet/sun/sunhme.c                    |    2 --
 drivers/net/ethernet/tehuti/tehuti.c                 |    1 -
 drivers/net/ethernet/ti/tlan.c                       |    1 -
 drivers/net/ethernet/toshiba/spider_net.c            |    1 -
 drivers/net/ethernet/toshiba/tc35815.c               |    1 -
 drivers/net/ethernet/via/via-rhine.c                 |    1 -
 59 files changed, 4 insertions(+), 103 deletions(-)
