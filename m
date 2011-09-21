From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 21 Sep 2011 16:30:44 -0400 (EDT)
Message-ID: <20110921.163044.182207467843169504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Highlights: IPSEC crash fix, ipv4 FIB rule BUG trigger fix, cure
wireless regression that hard-hangs some APs, eliminate deadlock in
ipw2x00 driver, add bluetooth device IDs for current generation
Mac Mini and Macbook Air.

1) Fix IPSEC crash due to misplaced replay check, from Steffen Klassert.

2) iwlagn revert as a workaround for behavior which has been found to
   hard-hang some wireless APs.  From Don Fry.

3) FIB rule insertion can trigger BUG in fib_nl_newrule() if the rule
   already has a ctarget.  Fix from Gao Feng.

4) Fix DMA address validation in IXGBE, from Jesse Brandeburg.

5) Fix tg3 VLAN regression on outbound packets, from Kasper Pedersen.

6) Fix pxa168_eth build failure, missing interrupt.h include, from Tanmay
   Upadhyay.

7) netconsole needs to init after built-in drivers, from Lin Ming.

8) gianfar classifier rule handler walks past end of array, fix from
   Ben Hutchings.

9) Fix MTU fragment calculations in ppp, we generate frags in situations
   where the packet actually fits.  From Henry WOng.

10) greth accidently corrupts computed checksum on TX, this happens in the
    case where the stack has fully computed the checksum already in sw.
    Fix from Daniel Hellstrom.

11) Fix double-free in ipv6_add_dev() failure path.  From Roy Li.

12) b43 should not issue wireless beacons in ad-hoc mode, fix from Manual Munz.

13) Add bluetooth device IDs for 2011 Mac Mini and Macbook Air, from Jurgen
    Kramer and Pieter-Augustijn Van Malleghem.

14) r8169 bug fixes from Hayes Wang and Francois Romieu:
    a) Make sure TX processes are really stopped on rtl8111ev1 before
       spinning on TXCFG_EMPTY bit to clear.
    b) Add missing MODULE_FIRMWARE entry for RTL8111E-VL
    c) Set proper RxConfig bits when wake-on-lan is enabled.
    d) Fix intepretation of RX descriptor status bits.
    e) Only check TBI bit in PHY status on old 8169 parts.

15) Make sure rate mask is updated properly in cfg80211_conn_scan(), from
    Rajkumar Manoharan.

16) rtl2800usb MAC address storage endian fix, from Larry Finger.

17) Fix rx2x00 compile error on PowerPC.

18) Fix RTNL mutex deadlock regression in ipw2x00 driver.  From Stanislaw Gruszka.

19) Make sure beacon hint flag is cleared when necessary, otherwise updates
    are ignored and lost.  From Rajkumar Manoharan.

20) Fix ordering of HCI_MGMT vs. HCI_INQUIRY state bits in bluetooth to
    fix scanning timeouts.  From Oliver Neukum.

Please pull, thanks a lot!

The following changes since commit 38867a28a7dc9d69389990bcd42f6b7c77da3d9d:

  Merge branch 'fixes' of git://git.linaro.org/people/arnd/arm-soc (2011-09-20 14:23:16 -0700)

are available in the git repository at:

  git://github.com/davem330/net.git master

Ben Hutchings (1):
      gianfar: Fix overflow check and return value for gfar_get_cls_all()

Chen Ganir (1):
      Bluetooth: Fixed BT ST Channel reg order

Daniel Hellstrom (2):
      GRETH: RX/TX bytes were never increased
      GRETH: avoid overwrite IP-stack's IP-frags checksum

David S. Miller (1):
      Merge branch 'davem.r8169.fixes' of git://violet.fr.zoreil.com/romieu/linux

Don Fry (1):
      iwlagn: workaround bug crashing some APs

Francois Romieu (2):
      r8169: remove erroneous processing of always set bit.
      r8169: do not enable the TBI for anything but the original 8169.

Gao feng (1):
      fib:fix BUG_ON in fib_nl_newrule when add new fib rule

Hayes Wang (3):
      r8169: fix the reset setting for 8111evl
      r8169: add MODULE_FIRMWARE for the firmware of 8111evl
      r8169: fix WOL setting for 8105 and 8111evl

Henry Wong (1):
      ppp_generic: fix multilink fragment MTU calculation (again)

Jesse Brandeburg (1):
      ixgbe: fix possible null buffer error

John W. Linville (2):
      Merge branch 'for-3.1' of git://github.com/padovan/bluetooth-next
      Merge branch 'master' of ssh://infradead/~/public_git/wireless into for-davem

Jurgen Kramer (1):
      Bluetooth: add support for 2011 mac mini

Kasper Pedersen (1):
      tg3: fix VLAN tagging regression

Larry Finger (2):
      rt2800pci: Fix compiler error on PowerPC
      rtl2800usb: Fix incorrect storage of MAC address on big-endian platforms

Lin Ming (1):
      netconsole: switch init_netconsole() to late_initcall

Manual Munz (1):
      b43: Fix beacon problem in ad-hoc mode

Oliver Neukum (1):
      Bluetooth: Fix timeout on scanning for the second time

Pieter-Augustijn Van Malleghem (1):
      Bluetooth: Add MacBookAir4,1 support

Rajkumar Manoharan (2):
      wireless: Reset beacon_found while updating regulatory
      wireless: Fix rate mask for scan request

Roy Li (1):
      ipv6: fix a possible double free

Stanislaw Gruszka (1):
      ipw2x00: fix rtnl mutex deadlock

Steffen Klassert (1):
      xfrm: Perform a replay check after return from async codepaths

Tanmay Upadhyay (1):
      net: pxa168: Fix build errors by including interrupt.h

 drivers/bluetooth/btusb.c               |    6 ++++
 drivers/bluetooth/btwilink.c            |   16 +++++-----
 drivers/net/gianfar_ethtool.c           |    8 ++--
 drivers/net/greth.c                     |   12 ++++++-
 drivers/net/greth.h                     |    1 +
 drivers/net/ixgbe/ixgbe_main.c          |    4 +-
 drivers/net/netconsole.c                |    8 ++++-
 drivers/net/ppp_generic.c               |    7 ++++-
 drivers/net/pxa168_eth.c                |    1 +
 drivers/net/r8169.c                     |   32 +++++++++++++++++---
 drivers/net/tg3.c                       |    2 -
 drivers/net/wireless/b43/main.c         |    3 +-
 drivers/net/wireless/ipw2x00/ipw2100.c  |   21 +++++++++----
 drivers/net/wireless/ipw2x00/ipw2200.c  |   39 +++++++++++++++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    5 +++
 drivers/net/wireless/rt2x00/rt2800lib.c |   47 +++++++++++++++++--------------
 net/bluetooth/hci_event.c               |   17 +++++------
 net/core/fib_rules.c                    |    4 +-
 net/ipv6/addrconf.c                     |    4 +-
 net/wireless/reg.c                      |    1 +
 net/wireless/sme.c                      |    2 +
 net/xfrm/xfrm_input.c                   |    5 +++
 22 files changed, 165 insertions(+), 80 deletions(-)
