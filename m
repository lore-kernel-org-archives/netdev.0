From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-11-18
Date: Tue, 18 Nov 2014 21:37:30 +0100
Message-ID: <1416343067-9810-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of 17 patches for net/master for the v3.18 relea=
se
cycle.

The last patch of this pull request ("can: m_can: update to support CAN=
 FD
features") adds, as the description says, a new feature to the m_can dr=
iver. As
the m_can driver has been added in v3.18 there is no risk of causing a
regression. Give me a note if this is not okay and I'll create a new pu=
ll
request without it.

There is a patch for the CAN infrastructure by Thomas K=C3=B6rper which=
 fixes
calling kfree_skb() from interrupt context. Roman Fietze fixes a typo a=
lso in
the infrastructure. A patch by Dong Aisheng adds a generic helper funct=
ion to
tell if a skb is normal CAN or CAN-FD frame. Alexey Khoroshilov of the =
Linux
Driver Verification project fixes a memory leak in the esd_usb2 driver.=
 Two
patches by Sudip Mukherjee remove unused variables and fixe the signess=
 of a
variable. Three patches by me add the missing .ndo_change_mtu callback =
to the
xilinx_can, rcar_can and gs_usb driver.

The remaining patches improve the m_can driver: David Cohen adds the mi=
ssing
CONFIG_HAS_IOMEM dependency. Dong Aisheng provides 6 bugfix patches (mo=
st
important: missing RAM init, sleep in NAPI poll, dlc in RTR). While the=
 last of
his patches adds CAN FD support to the driver.

regards,
Marc

---

The following changes since commit feb91a02ccb09661507f170b2a444aec94f3=
07f9:

  ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs (20=
14-11-16 16:55:06 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-=
3.18-20141118

for you to fetch changes up to 80646733f11c2e9de3b6339f7e635047e6087280=
:

  can: m_can: update to support CAN FD features (2014-11-18 21:35:06 +0=
100)

----------------------------------------------------------------
linux-can-fixes-for-3.18-20141118

----------------------------------------------------------------
Alexey Khoroshilov (1):
      can: esd_usb2: fix memory leak on disconnect

David Cohen (1):
      can: m_can: add CONFIG_HAS_IOMEM dependence

Dong Aisheng (8):
      can: dev: add can_is_canfd_skb() API
      can: m_can: add .ndo_change_mtu function
      can: m_can: add missing message RAM initialization
      can: m_can: fix possible sleep in napi poll
      can: m_can: fix not set can_dlc for remote frame
      can: m_can: add missing delay after setting CCCR_INIT bit
      can: m_can: fix incorrect error messages
      can: m_can: update to support CAN FD features

Marc Kleine-Budde (3):
      can: xilinx_can: add .ndo_change_mtu function
      can: rcar_can: add .ndo_change_mtu function
      can: gs_usb: add .ndo_change_mtu function

Roman Fietze (1):
      can: dev: fix typo CIA -> CiA, CAN in Automation

Sudip Mukherjee (2):
      can: remove unused variable
      can: xilinx_can: fix comparison of unsigned variable

Thomas K=C3=B6rper (1):
      can: dev: avoid calling kfree_skb() from interrupt context

 drivers/net/can/dev.c                |   4 +-
 drivers/net/can/m_can/Kconfig        |   1 +
 drivers/net/can/m_can/m_can.c        | 219 ++++++++++++++++++++++++++-=
--------
 drivers/net/can/rcar_can.c           |   1 +
 drivers/net/can/sja1000/kvaser_pci.c |   5 +-
 drivers/net/can/usb/ems_usb.c        |   3 +-
 drivers/net/can/usb/esd_usb2.c       |   3 +-
 drivers/net/can/usb/gs_usb.c         |   1 +
 drivers/net/can/xilinx_can.c         |   4 +-
 include/linux/can/dev.h              |   6 +
 10 files changed, 183 insertions(+), 64 deletions(-)

