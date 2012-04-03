From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 02 Apr 2012 20:34:42 -0400 (EDT)
Message-ID: <20120402.203442.1793134339535157754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab2DCAer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 20:34:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Provide device string properly for USB i2400m wimax devices, also don't
   OOPS when providing firmware string.  From Phil Sutter.

2) Add support for sh_eth SH7734 chips, from Nobuhiro Iwamatsu.

3) Add another device ID to USB zaurus driver, from Guan Xin.

4) Loop index start in pool vector iterator is wrong causing MAC to
   not get configured in bnx2x driver, fix from Dmitry Kravkov.

5) EQL driver assumes HZ=100, fix from Eric Dumazet.

6) Now that skb_add_rx_frag() can specify the truesize increment
   separately, do so in f_phonet and cdc_phonet, also from Eric
   Dumazet.

7) virtio_net accidently uses net_ratelimit() not only on the kernel
   warning but also the statistic bump, fix from Rick Jones.

8) ip_route_input_mc() uses fixed init_net namespace, oops, use
   dev_net(dev) instead.  Fix from Benjamin LaHaise.

9) dev_forward_skb() needs to clear the incoming interface index of
   the SKB so that it looks like a new incoming packet, also from
   Benjamin LaHaise.

10) iwlwifi mistakenly initializes a channel entry as 2GHZ instead
    of 5GHZ, fix from Stanislav Yakovlev.

11) Missing kmalloc() return value checks in orinoco, from Santosh
    Nayak.

12) ath9k doesn't check for HT capabilities in the right way, it
    is checking ht_supported instead of the ATH9K_HW_CAP_HT flag.
    Fix from Sujith Manoharan.

13) Fix x86 BPF JIT emission of 16-bit immediate field of AND
    instructions, from Feiran Zhuang.

14) Avoid infinite loop in GARP code when registering sysfs entries.
    From David Ward.

15) rose protocol uses memcpy instead of memcmp in a device address
    comparison, oops.  Fix from Daniel Borkmann.

16) Fix build of lpc_eth due to dev_hw_addr_rancom() interface being
    renamed to eth_hw_addr_random().  From Roland Stigge.

17) Make ipv6 RTM_GETROUTE interpret RTA_IIF attribute the same way
    that ipv4 does.  Fix from Shmulik Ladkani.

18) via-rhine has an inverted bit test, causing suspend/resume regressions.
    Fix from Andreas Mohr.

19) RIONET assumes 4K page size, fix from Akinobu Mita.

20) Initialization of imask register in sky2 is buggy, because
    bits are "or'd" into an uninitialized local variable.  Fix
    from Lino Sanfilippo.

21) Fix FCOE checksum offload handling, from Yi Zou.

22) Fix VLAN processing regression in e1000, from Jiri Pirko.

Please pull, thanks a lot!

The following changes since commit b1a808ff436343956a6ae63178ea1810c5e5a3a1:

  Merge branch 'for-next' of git://gitorious.org/kernel-hsi/kernel-hsi (2012-04-02 09:50:40 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Akinobu Mita (1):
      rionet: fix page allocation order of rionet_active

Alexander Duyck (1):
      ixgbe: Fix issues with SR-IOV loopback when flow control is disabled

Andreas Mohr (1):
      via-rhine: fix wait-bit inversion.

Andrew Morton (1):
      net/netfilter/nfnetlink_acct.c: use linux/atomic.h

Benjamin LaHaise (2):
      net/ipv4: fix IPv4 multicast over network namespaces
      net/core: dev_forward_skb() should clear skb_iif

Bob Copeland (1):
      ath5k: drop self from MAINTAINERS

Dan Carpenter (1):
      mISDN: array underflow in open_bchannel()

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../jkirsher/net
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless

David Ward (1):
      net/garp: avoid infinite loop if attribute already exists

Dmitry Kravkov (1):
      bnx2x: fix vector traveling while looking for an empty entry

Don Skidmore (2):
      ixgbe: fix typo in enumeration name
      ixgbe: update version number

Eliad Peller (1):
      mac80211: remove outdated comment

Eric Dumazet (4):
      ath9k: fix a memory leak in ath_rx_tasklet()
      eql: dont rely on HZ=100
      f_phonet: fix skb truesize underestimation
      cdc-phonet: fix skb truesize underestimation

Guan Xin (1):
      USB: Add Motorola Rokr E6 Id to the USBNet driver "zaurus"

Jeff Kirsher (3):
      Merge branch 'master' of git://git.kernel.org/.../davem/net
      Merge branch 'master' of git://git.kernel.org/.../davem/net
      Merge branch 'master' of git://git.kernel.org/.../davem/net

Jiri Pirko (1):
      e1000: fix vlan processing regression

John W. Linville (1):
      cfg80211: allow CFG80211_SIGNAL_TYPE_UNSPEC in station_info

Kenth Eriksson (1):
      Fix non TBI PHY access; a bad merge undid bug fix in a previous commit.

Larry Finger (1):
      rtlwifi: rtl8192ce: rtl8192cu: rtl8192de: Fix low-gain setting when scanning

Lino Sanfilippo (1):
      sky2: dont overwrite settings for PHY Quick link

Matt Carlson (1):
      tg3: Fix 5717 serdes powerdown problem

Nobuhiro Iwamatsu (1):
      net: sh_eth: Add support SH7734

Phil Sutter (2):
      wimax: i2400m - prevent a possible kernel bug due to missing fw_name string
      wimax: i2400m-usb - use a private struct ethtool_ops

Rabin Vincent (1):
      net: usb: cdc_eem: fix mtu

Rajkumar Manoharan (3):
      ath9k: fix max noise floor threshold
      ath9k: reduce listen time period
      mac80211: fix oper channel timestamp updation

Rick Jones (1):
      virtio_net: do not rate limit counter increments

Santosh Nayak (1):
      net: orinoco: add error handling for failed kmalloc().

Shmulik Ladkani (1):
      ipv6: Fix RTM_GETROUTE's interpretation of RTA_IIF to be consistent with ipv4

Stanislav Yakovlev (2):
      net/wireless: ipw2x00: fix a typo in wiphy struct initilization
      MAINTAINERS: adding maintainer for ipw2x00

Stanislaw Gruszka (5):
      iwlegacy: do not nulify il->vif on reset
      iwlegacy: fix BSSID setting
      rt2x00: rt2800usb: schedule txdone work on timeout
      rt2x00: rt2800usb: fix status register reread logic
      mac80211: fix possible tid_rx->reorder_timer use after free

Sujith Manoharan (1):
      ath9k: Use HW HT capabilites properly

Weiping Pan (1):
      bonding: emit event when bonding changes MAC

Yi Zou (2):
      net: do not do gso for CHECKSUM_UNNECESSARY in netif_needs_gso
      fcoe: use CHECKSUM_UNNECESSARY instead of CHECKSUM_PARTIAL on tx

Yoshihiro Shimoda (1):
      net: sh_eth: fix endian check for architecture independent

Yuval Mintz (1):
      bnx2x: previous driver unload revised

danborkmann@iogearbox.net (1):
      rose_dev: fix memcpy-bug in rose_set_mac_address

huajun li (1):
      usb/rtl8150 : Remove duplicated definitions

stephen hemminger (1):
      intel: make wired ethernet driver message level consistent (rev2)

stigge@antcom.de (1):
      net: lpc_eth: Fix rename of dev_hw_addr_random

zhuangfeiran@ict.ac.cn (1):
      x86 bpf_jit: fix a bug in emitting the 16-bit immediate operand of AND

 MAINTAINERS                                        |   13 +-
 arch/x86/net/bpf_jit_comp.c                        |    2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c             |    2 +-
 drivers/isdn/hardware/mISDN/hfcpci.c               |    2 +-
 drivers/isdn/hardware/mISDN/hfcsusb.c              |    2 +-
 drivers/isdn/hardware/mISDN/mISDNipac.c            |    2 +-
 drivers/isdn/hardware/mISDN/mISDNisar.c            |    2 +-
 drivers/isdn/hardware/mISDN/netjet.c               |    2 +-
 drivers/isdn/hardware/mISDN/w6692.c                |    2 +-
 drivers/net/bonding/bond_main.c                    |    8 +-
 drivers/net/eql.c                                  |    7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    7 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   40 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |    3 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    1 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  464 ++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                |    4 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |   12 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |   40 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    7 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    7 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    7 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   13 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    7 +-
 drivers/net/ethernet/marvell/sky2.c                |    5 +-
 drivers/net/ethernet/nxp/lpc_eth.c                 |    2 +-
 drivers/net/ethernet/renesas/Kconfig               |    5 +-
 drivers/net/ethernet/renesas/sh_eth.c              |   22 +-
 drivers/net/ethernet/renesas/sh_eth.h              |   15 +-
 drivers/net/ethernet/via/via-rhine.c               |   12 +-
 drivers/net/rionet.c                               |   11 +-
 drivers/net/usb/cdc-phonet.c                       |    4 +-
 drivers/net/usb/cdc_eem.c                          |    1 +
 drivers/net/usb/rtl8150.c                          |   26 --
 drivers/net/usb/zaurus.c                           |    5 +
 drivers/net/virtio_net.c                           |    7 +-
 drivers/net/wimax/i2400m/netdev.c                  |    3 +-
 drivers/net/wimax/i2400m/usb.c                     |   18 +
 drivers/net/wireless/ath/ath9k/calib.c             |    5 +-
 drivers/net/wireless/ath/ath9k/init.c              |    2 +-
 drivers/net/wireless/ath/ath9k/main.c              |    4 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    4 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    4 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |    2 -
 drivers/net/wireless/iwlegacy/4965-mac.c           |    2 -
 drivers/net/wireless/iwlegacy/common.c             |   31 +-
 drivers/net/wireless/orinoco/main.c                |    8 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |    2 +-
 drivers/usb/gadget/f_phonet.c                      |    2 +-
 include/linux/if_eql.h                             |    2 +-
 include/net/cfg80211.h                             |    6 +-
 net/802/garp.c                                     |   22 +-
 net/core/dev.c                                     |    1 +
 net/ipv4/route.c                                   |    2 +-
 net/ipv6/route.c                                   |   34 ++-
 net/mac80211/agg-rx.c                              |    3 +-
 net/mac80211/main.c                                |    3 -
 net/mac80211/scan.c                                |    2 +-
 net/netfilter/nfnetlink_acct.c                     |    2 +-
 net/rose/rose_dev.c                                |    4 +-
 net/wireless/nl80211.c                             |   29 +-
 69 files changed, 705 insertions(+), 294 deletions(-)
