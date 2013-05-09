From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 08 May 2013 18:01:21 -0700 (PDT)
Message-ID: <20130508.180121.2184743580101786921.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Propagate return error values properly in irda, spider_net, sfc,
   and bfin_mac.  From Wei Yongjun.

2) Fix fec driver OOPS on rapid link up/down, from Frank Li.

3) FIX VF resource allocation and chip message payload length errors
   in be2net driver, from Sathya Perla.

4) Fix inner protocol inspection during GSO from Pravin B Shelar.

Please pull, thanks a lot!

The following changes since commit de9c9f86be0dc3495de98dc65c80abe6e7c7d643:

  Merge tag 'remoteproc-3.10' of git://git.kernel.org/pub/scm/linux/kernel/git/ohad/remoteproc (2013-05-07 14:04:56 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 4f924b2aa4d3cb30f07e57d6b608838edcbc0d88:

  if_cablemodem.h: Add parenthesis around ioctl macros (2013-05-08 13:13:30 -0700)

----------------------------------------------------------------
Dan Williams (3):
      qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel E371) WWAN card
      usbnet: allow status interrupt URB to always be active
      sierra_net: keep status interrupt URB active

Frank Li (1):
      net: fec: fix kernel oops when plug/unplug cable many times

Josh Boyer (1):
      if_cablemodem.h: Add parenthesis around ioctl macros

Pravin B Shelar (1):
      gso: Handle Trans-Ether-Bridging protocol in skb_network_protocol()

Sathya Perla (4):
      be2net: provision VF resources before enabling SR-IOV
      be2net: fix payload_len value for GET_MAC_LIST cmd req
      be2net: fix EQ from getting full while cleaning RX CQ
      be2net: disable TX in be_close()

Sebastian Hesselbarth (1):
      net: of_mdio: fix behavior on missing phy device

Wei Yongjun (4):
      net/irda: fix error return code in bfin_sir_open()
      net/spider_net: fix error return code in spider_net_open()
      sfc: fix return value check in efx_ptp_probe_channel()
      bfin_mac: fix error return code in bfin_mac_probe()

 drivers/net/ethernet/adi/bfin_mac.c         |  3 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c |  5 ++---
 drivers/net/ethernet/emulex/benet/be_main.c | 30 +++++++++++++++-------------
 drivers/net/ethernet/freescale/fec.h        | 10 ++++++----
 drivers/net/ethernet/freescale/fec_main.c   | 44 ++++++++++++++++++++++++++++++-----------
 drivers/net/ethernet/sfc/ptp.c              |  4 +++-
 drivers/net/ethernet/toshiba/spider_net.c   |  3 ++-
 drivers/net/irda/bfin_sir.c                 |  6 ++++--
 drivers/net/usb/cdc_ether.c                 |  7 +++++++
 drivers/net/usb/qmi_wwan.c                  |  7 +++++++
 drivers/net/usb/sierra_net.c                | 38 ++++++++++++++++++++++++++++-------
 drivers/net/usb/usbnet.c                    | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 drivers/of/of_mdio.c                        | 11 ++++-------
 include/linux/usb/usbnet.h                  |  5 +++++
 include/uapi/linux/if_cablemodem.h          | 12 +++++------
 net/core/dev.c                              | 11 +++++++++++
 net/ipv4/gre.c                              |  8 +-------
 net/ipv4/udp.c                              |  4 +---
 18 files changed, 212 insertions(+), 73 deletions(-)
