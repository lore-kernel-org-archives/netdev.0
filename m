From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 09 Mar 2012 01:29:42 -0800 (PST)
Message-ID: <20120309.012942.1947357900237897108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) IPV4 routing metrics can become stale when routes are changed
   by the administrator, fix from Steffen Klassert.

2) atl1c does "val |= XXX;" where XXX is a bit number not a bit mask,
   fix by using set_bit.  From Dan Carpenter.

3) Memory accounting bug in carl9170 driver results in wedged TX
   queue.  Fix from Nicolas Cavallari.

4) iwlwifi accidently uses "sizeof(ptr)" instead of "sizeof(*ptr)",
   fix from Johannes Berg.

5) Openvswitch doesn't honor dp_ifindex when doing vport lookups, fix
   from Ben Pfaff.

6) ehea conversion to 64-bit stats lost multicast and rx_errors
   accounting, fix from Eric Dumazet.

7) Bridge state transition logging in br_stp_disable_port() is busted,
   it's emitted at the wrong time and the message is in the wrong tense,
   fix from Paulius Zaleckas.

8) mlx4 device erroneously invokes the queue resize firmware operation
   twice, fix from Jack Morgenstein.

9) Fix deadlock in usbnet, need to drop lock when invoking usb_unlink_urb()
   otherwise we recurse into taking it again.  Fix from Sebastian Siewior.

10) hyperv network driver uses the wrong driver name string, fix from
    Haiyang Zhang.

Please pull, thanks a lot!

The following changes since commit 4f262acfde22b63498b5e4f165e53d3bb4e96400:

  Merge branch 'fixes' of git://git.linaro.org/people/rmk/linux-arm (2012-03-07 08:33:03 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

Amitkumar Karwar (1):
      mwifiex: reset encryption mode flag before association

Ben Pfaff (1):
      openvswitch: Honor dp_ifindex, when specified, for vport lookup by name.

Christian Lamparter (1):
      carl9170: fix frame delivery if sta is in powersave mode

Dan Carpenter (1):
      atl1c: set ATL1C_WORK_EVENT_RESET bit correctly

David S. Miller (2):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless
      Merge branch 'fixes' of git://git.kernel.org/.../jesse/openvswitch

Eric Dumazet (1):
      ehea: restore multicast and rx_errors fields

Haiyang Zhang (1):
      net/hyperv: Use the built-in macro KBUILD_MODNAME for this driver

Jack Morgenstein (1):
      mlx4_core: fix bug in modify_cq wrapper for resize flow.

Jesse Gross (1):
      openvswitch: Fix checksum update for actions on UDP packets.

Johannes Berg (1):
      iwlwifi: fix wowlan suspend

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Nicolas Cavallari (1):
      carl9170: Fix memory accounting when sta is in power-save mode.

Paulius Zaleckas (2):
      bridge: br_log_state() s/entering/entered/
      bridge: fix state reporting when port is disabled

Sebastian Siewior (1):
      net/usbnet: avoid recursive locking in usbnet_stop()

Steffen Klassert (2):
      inetpeer: Invalidate the inetpeer tree along with the routing cache
      route: Remove redirect_genid

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    4 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +-
 drivers/net/hyperv/netvsc_drv.c                    |    4 +-
 drivers/net/usb/usbnet.c                           |    2 +
 drivers/net/wireless/ath/carl9170/tx.c             |    9 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    1 +
 include/net/inetpeer.h                             |    4 +-
 net/bridge/br_stp.c                                |    2 +-
 net/bridge/br_stp_if.c                             |    3 +-
 net/ipv4/inetpeer.c                                |   81 +++++++++++++++++++-
 net/ipv4/route.c                                   |   12 +--
 net/openvswitch/actions.c                          |   44 ++++++++---
 net/openvswitch/datapath.c                         |    3 +
 15 files changed, 139 insertions(+), 37 deletions(-)
