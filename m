From: Tejun Heo <tj@kernel.org>
Subject: [PATCHSET] net-dev: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:52:56 +0100
Message-ID: <1292169185-10579-1-git-send-email-tj@kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56516 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367Ab0LLPxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 10:53:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patchset removes the use of flush_scheduled_work(), which is
being deprecated, from various network drivers.  It contains the
following nine patches.

 0001-drivers-net-remove-unnecessary-flush_scheduled_work-.patch
 0002-drivers-net-don-t-use-flush_scheduled_work.patch
 0003-ehea-kill-unused-ehea_rereg_mr_task.patch
 0004-ehea-don-t-use-flush_scheduled_work.patch
 0005-iseries_veth-don-t-use-flush_scheduled_work.patch
 0006-igb-v-ixgbe-don-t-use-flush_scheduled_work.patch
 0007-sungem-update-gp-reset_task-flushing.patch
 0008-i2400m-drop-i2400m_schedule_work.patch
 0009-hostap-don-t-use-flush_scheduled_work.patch

0001 and 0002 are straight forward conversions across multiple network
drivers.  The rest are a bit more involved per-driver or driver family
conversions.

This patchset is on top of the current net-next-2.6.git#master
(ad1184c6cf067a13e8cb2a4e7ccc407f947027d0) and available in the
following git branch.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/wq.git net-dev-kill-flush_scheduled_work

diffstat follows.  Thanks.

 drivers/net/8139too.c                   |    3 -
 drivers/net/atlx/atl2.c                 |    4 -
 drivers/net/bcm63xx_enet.c              |    2 
 drivers/net/bnx2.c                      |    4 -
 drivers/net/can/janz-ican3.c            |    9 ---
 drivers/net/cassini.c                   |    4 -
 drivers/net/cxgb3/cxgb3_main.c          |    3 -
 drivers/net/e1000e/netdev.c             |    6 +-
 drivers/net/ehea/ehea.h                 |    2 
 drivers/net/ehea/ehea_main.c            |   14 +---
 drivers/net/enic/enic_main.c            |    2 
 drivers/net/ibm_newemac/core.c          |    2 
 drivers/net/igb/igb_main.c              |    9 ++-
 drivers/net/igbvf/netdev.c              |    7 +-
 drivers/net/irda/mcs7780.c              |    2 
 drivers/net/iseries_veth.c              |   18 +-----
 drivers/net/ixgb/ixgb_main.c            |    2 
 drivers/net/ixgbe/ixgbe_main.c          |   11 ++-
 drivers/net/ixgbevf/ixgbevf_main.c      |    3 -
 drivers/net/mv643xx_eth.c               |    2 
 drivers/net/myri10ge/myri10ge.c         |    2 
 drivers/net/niu.c                       |    2 
 drivers/net/pxa168_eth.c                |    2 
 drivers/net/r8169.c                     |    2 
 drivers/net/s2io.c                      |    6 +-
 drivers/net/sh_eth.c                    |    1 
 drivers/net/sh_eth.h                    |    1 
 drivers/net/sis190.c                    |    3 -
 drivers/net/skge.c                      |    2 
 drivers/net/sungem.c                    |   12 +---
 drivers/net/tg3.c                       |    4 -
 drivers/net/usb/sierra_net.c            |    5 -
 drivers/net/usb/usbnet.c                |    3 -
 drivers/net/vmxnet3/vmxnet3_drv.c       |    2 
 drivers/net/vxge/vxge-main.c            |    2 
 drivers/net/wimax/i2400m/driver.c       |   96 +++++---------------------------
 drivers/net/wimax/i2400m/i2400m.h       |   19 +-----
 drivers/net/wimax/i2400m/sdio.c         |    1 
 drivers/net/wimax/i2400m/usb.c          |    1 
 drivers/net/wireless/hostap/hostap_ap.c |    3 +
 drivers/net/wireless/hostap/hostap_hw.c |    8 ++
 41 files changed, 97 insertions(+), 189 deletions(-)

--
tejun
