From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 04 Jan 2012 16:11:14 -0500 (EST)
Message-ID: <20120104.161114.1924910384933450343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Probably the bluetooth 10 second resume delay fix is the most
interesting fix here, especially if you're actually hitting it.

The rest are small fixes isolated to specific drivers or packet
schedulers.

1) Revert bluetooth HCI reset timeout increase, it adds a 10 second delay
   during resume in Thinkpad laptops and potentially other machines.  From
   Gustavo F. Padovan.

2) New packet QFQ scheduler using wrong types to compute queueing limits
   leading to overflows, fix from Eric Dumazet.

3) Fix regression in b43 driver conversion to new RX descriptor header
   format, it broke PIO mode where the header length needs to be computed
   differently.  Fix from Guennadi Liakhovetski.

4) Fix build dependencies of FEC ethernet driver, from Wolfram Sang.

5) mwifiex gets OOPS when scan and connect occur simultaneously, fix from
   Amitkumar Karwar.

6) ath9k crashes in access point mode because it does aggregation
   handling during power save even if TX aggregation is not enabled.
   Fix from Mohammed Shafi Shajakhan.

7) Update CAN MAINTAINERS entry, from Oliver Hartkopp.

Please pull, thanks a lot!

The following changes since commit f423fc627b05f47bc9305f9661630fce30f208f9:

  Revert "rtc: Expire alarms after the time is set." (2012-01-04 07:57:22 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Amitkumar Karwar (1):
      mwifiex: fix crash during simultaneous scan and connect

Eric Dumazet (1):
      sch_qfq: fix overflow in qfq_update_start()

Guennadi Liakhovetski (1):
      b43: fix regression in PIO case

Gustavo F. Padovan (1):
      Revert "Bluetooth: Increase HCI reset timeout in hci_dev_do_close"

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic in AR2427 in AP mode

Oliver Hartkopp (2):
      CAN MAINTAINERS update
      fix CAN MAINTAINERS SCM tree type

Wolfram Sang (1):
      net: fsl: fec: fix build for mx23-only kernel

 MAINTAINERS                              |   11 +++++------
 drivers/net/ethernet/freescale/Kconfig   |    4 ++--
 drivers/net/wireless/ath/ath9k/main.c    |    3 +++
 drivers/net/wireless/b43/pio.c           |   16 +++++++++++++---
 drivers/net/wireless/mwifiex/sta_ioctl.c |    7 ++++++-
 net/bluetooth/hci_core.c                 |    2 +-
 net/sched/sch_qfq.c                      |    4 ++--
 7 files changed, 32 insertions(+), 15 deletions(-)
