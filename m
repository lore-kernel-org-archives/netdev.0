From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 27 Aug 2015 17:42:59 -0700 (PDT)
Message-ID: <20150827.174259.1261630254257255817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some straggler bug fixes here:

1) Netlink_sendmsg() doesn't check iterator type properly in mmap case,
   from Ken-ichirou MATSUZAWA.

2) Don't sleep in atomic context in bcmgenet driver, from Florian
   Fainelli.

3) The pfkey_broadcast() code patch can't actually ever use anything other
   than GFP_ATOMIC.  And the cases that right now pass GFP_KERNEL or similar
   will currently trigger an RCU splat.  Just use GFP_ATOMIC unconditionally.
   From David Ahern.

4) Fix FD bit timings handling in pcan_usb driver, from Marc
   Kleine-Budde.

5) Cache dst leaked in ip6_gre tunnel removal, fix from Huaibin Wang.

6) Traversal into drivers/net/ethernet/renesas should be triggered by
   CONFIG_NET_VENDOR_RENESAS, not a particular driver's config option.
   From Kazuya Mizuguchi.

7) Fix regression in handling of igmp_join errors in vxlan, from
   Marcelo Ricardo Leitner.

8) Make phy_{read,write}_mmd_indirect() properly take the mdio_lock mutex
   when programming the registers.  From Russell King.

9) Fix non-forced handling in u32_destroy(), from WANG Cong.

10) Test the EVENT_NO_RUNTIME_PM flag before it is cleared in
    usbnet_stop(), from Eugene Shatokhin.

11) In sfc driver, don't fetch statistics firmware isn't capable of,
    from Bert Kenward.

12) Verify ASCONF address parameter location in SCTP, from Xin Long.

Please pull, thanks a lot!

The following changes since commit 0bad90985d39e69ca035fdd70bcc743812641d18:

  Merge tag 'pm+acpi-4.2-rc8' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2015-08-20 17:06:11 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to f648f807f61e64d247d26611e34cc97e4ed03401:

  sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE state (2015-08-27 17:11:44 -0700)

----------------------------------------------------------------
Bert Kenward (1):
      sfc: only use vadaptor stats if firmware is capable

David Ahern (1):
      net: Fix RCU splat in af_key

David Daney (1):
      phylib: Make PHYs children of their MDIO bus, not the bus' parent.

David S. Miller (1):
      Merge tag 'linux-can-fixes-for-4.2-20150825' of git://git.kernel.org/.../mkl/linux-can

Eugene Shatokhin (1):
      usbnet: Get EVENT_NO_RUNTIME_PM bit before it is cleared

Florian Fainelli (1):
      net: bcmgenet: Avoid sleeping in bcmgenet_timeout

Iyappan Subramanian (1):
      drivers: net: xgene: fix: Oops in linkwatch_fire_event

Jaedon Shin (1):
      net: bcmgenet: fix uncleaned dma flags

Kazuya Mizuguchi (1):
      net: compile renesas directory if NET_VENDOR_RENESAS is configured

Ken-ichirou MATSUZAWA (1):
      netlink: mmap: fix tx type check

Madalin Bucur (1):
      net: phy: fixed: propagate fixed link values to struct

Marc Kleine-Budde (1):
      can: pcan_usb: don't provide CAN FD bittimings by non-FD adapters

Marcelo Ricardo Leitner (1):
      vxlan: re-ignore EADDRINUSE from igmp_join

Russell King (2):
      net: phy: add locking to phy_read_mmd_indirect()/phy_write_mmd_indirect()
      net: fec: use reinit_completion() in mdio accessor functions

WANG Cong (1):
      cls_u32: complete the check for non-forced case in u32_destroy()

huaibin Wang (1):
      ip6_gre: release cached dst on tunnel removal

lucien (2):
      sctp: asconf's process should verify address parameter is in the beginning
      sctp: donot reset the overall_error_count in SHUTDOWN_RECEIVE state

 drivers/net/can/usb/peak_usb/pcan_usb.c          | 24 ++++++++++---------
 drivers/net/can/usb/peak_usb/pcan_usb_core.c     |  4 ++--
 drivers/net/can/usb/peak_usb/pcan_usb_core.h     |  4 ++--
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c       | 96 ++++++++++++++++++++++++++++++++++++++++----------------------------------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c      | 24 ++++++++++---------
 drivers/net/ethernet/Makefile                    |  2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |  3 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  5 ++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.c   | 20 ++++++++++++----
 drivers/net/ethernet/freescale/fec_main.c        |  4 ++--
 drivers/net/ethernet/sfc/ef10.c                  | 27 ++++++++++++++++++++-
 drivers/net/phy/fixed_phy.c                      |  9 +++++++
 drivers/net/phy/phy.c                            | 16 +++++++++----
 drivers/net/phy/phy_device.c                     |  2 +-
 drivers/net/usb/usbnet.c                         |  7 +++---
 drivers/net/vxlan.c                              |  2 ++
 net/ipv6/ip6_gre.c                               |  1 +
 net/key/af_key.c                                 | 46 +++++++++++++++++------------------
 net/netlink/af_netlink.c                         |  2 +-
 net/sched/cls_u32.c                              | 13 ++++++++++
 net/sctp/sm_make_chunk.c                         |  7 ++++++
 net/sctp/sm_sideeffect.c                         |  2 +-
 22 files changed, 207 insertions(+), 113 deletions(-)
