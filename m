From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 20 Dec 2009 19:43:35 -0800 (PST)
Message-ID: <20091220.194335.39201371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345AbZLUDne convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2009 22:43:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the bug fixes which have accumulated over the past
week or so.

1) gc_min_interval_ms ipv6 sysctl doesn't update per-namespace
   properly, fix from Alexey Dobriyan.

2) Bluetooth bug fixes from Gustavo F. Padovan, Oliver Neukum,
   Roel Kluin, and Andrei Emeltchenko.

3) Fix e1000e LED settings on 82571 and 82572 chips, fix from
   Bruce Allan.

4) bnx2 crash in reset_task fix from Breno Leitao.

5) TI DaVinci EMAC MDIO bus frequence programming fix from
   Nageswari Srinivasan.

6) e100 regression fix from Roger Oksanen.  When we moved this
   driver over to pci pools, we added a subtle bug because
   pci pool objects, unlike pci_alloc_consistent() allocations,
   do not get bzero()'d out for the caller.

7) gianfar fixes from Sandeep Gopalpet.

8) netxen sysfs fix from Stephen Hemminger

9) mISDN needs to use DECLARE_COMPLETION_ONSTACK, fix from Yong Zhang

Please pull, thanks a lot!

The following changes since commit dd59f6c76b265ed2ff18b497d6105a9511b1=
feb1:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../mattst88/a=
lpha-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexey Dobriyan (1):
      netns: fix net.ipv6.route.gc_min_interval_ms in netns

Andrei Emeltchenko (1):
      Bluetooth: Fix L2CAP locking scheme regression

Breno Leitao (2):
      bnx2: reset_task is crashing the kernel. Fixing it.
      bnx2: fixing a timout error due not refreshing TX timers correctl=
y

Bruce Allan (1):
      e1000e: LED settings in EEPROM ignored on 82571 and 82572

Gustavo F. Padovan (2):
      Bluetooth: Fix unset of RemoteBusy flag for L2CAP
      Bluetooth: Ack L2CAP I-frames before retransmit missing packet

Michael Chan (1):
      bnx2: Fix bnx2_netif_stop() merge error.

Nageswari Srinivasan (1):
      TI DaVinci EMAC: Fix MDIO bus frequency configuration

Oliver Neukum (1):
      Bluetooth: Prevent ill-timed autosuspend in USB driver

Roel Kluin (2):
      Bluetooth: Fix PTR_ERR return of wrong pointer in hidp_setup_hid(=
)
      broadcom: bcm54xx_shadow_read() errors ignored in bcm54xx_adjust_=
rxrefclk()

Roger Oksanen (1):
      e100: Fix broken cbs accounting due to missing memset.

Sandeep Gopalpet (3):
      gianfar: Fix a filer bug
      gianfar: Fix stats support
      gianfar: Fix bit definitions of IMASK_GRSC and IMASK_GTSC

Stephen Hemminger (1):
      netxen: use module parameter correctly

Uwe Kleine-K=F6nig (1):
      can/at91: don't check platform_get_irq's return value against zer=
o

Yang Hongyang (1):
      ipv6: fix an oops when force unload ipv6 module

Yong Zhang (1):
      mISDN: use DECLARE_COMPLETION_ONSTACK for non-constant completion

 drivers/bluetooth/btusb.c            |    1 +
 drivers/isdn/mISDN/l1oip_core.c      |    2 +-
 drivers/net/bnx2.c                   |   12 ++++++-
 drivers/net/can/at91_can.c           |    2 +-
 drivers/net/davinci_emac.c           |    2 +-
 drivers/net/e100.c                   |    2 +-
 drivers/net/e1000e/82571.c           |    6 ---
 drivers/net/gianfar.c                |   50 +++++++++++++++++++++++++-=
---
 drivers/net/gianfar.h                |   18 +++++++++-
 drivers/net/netxen/netxen_nic_main.c |   57 ++------------------------=
--------
 drivers/net/phy/broadcom.c           |    3 +-
 net/bluetooth/hidp/core.c            |    2 +-
 net/bluetooth/l2cap.c                |    5 ++-
 net/ipv6/reassembly.c                |    3 +-
 net/ipv6/route.c                     |    1 +
 15 files changed, 86 insertions(+), 80 deletions(-)
