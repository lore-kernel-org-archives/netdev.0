From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 03 May 2008 03:00:01 -0700 (PDT)
Message-ID: <20080503.030001.245680815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755258AbYECKAB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 May 2008 06:00:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is what has accumulated the past few days:

1) Set of patches from Denis V. Lunev which fix the
   procfs "pde->data not setup before grafting new node
   under /proc" bug in several networking spots.

2) When we get a transmit timeout, that's a pretty serious error
   and it's useful to have a backtrace, thus add a WARN_ON_ONCE().
   From Arjan van de Ven.

3) sysfs network device renaming fix, and a ipv6 fragmentation
   queue namespace fix, from Daniel Lezcano.

4) Several wireless bug fixes from John Linville and the wireless
   crew.

5) Several changes from Harvy Harrison, mostly to use recently
   added infrastructure such as clamp and get_unaligned_${ENDIAN}${SZ}

6) Ilpo spotted some scary cases of missing braces hidden from humans
   by mis-indented code.

7) TG3 and BNX2 driver updates from Matt Carlson and Michael Chan.

8) Some bridge layer interfaces could only handle up to 256 devices,
   fix from Stephen Hemminger.

9) Some de-NR_CPUS'ification in net/core/dev.c from Mike Travis.

10) usb bluetooth driver race fix from Pavel Machek

11) Bernard Pidoux found incorrect locking as well as bad sparse
    locking annotations in AF_ROSE.

Please pull, thanks a lot!

The following changes since commit e4c576b911e364737b1bf4f5bfdab1c44071=
3f26:
  Theodore Ts'o (1):
        Update .gitignore to include include/linux/bounds.h

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Arjan van de Ven (1):
      net: Add a WARN_ON_ONCE() to the transmit timeout function

Bernard Pidoux (1):
      rose: Wrong list_lock argument in rose_node seqops

Bill Moss (1):
      iwlwifi: fix debug messages during scanning

Daniel Lezcano (2):
      netns: Fix device renaming for sysfs
      netns: Fix reassembly timer to use the right namespace

David S. Miller (2):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-2.6
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-2.6

Denis V. Lunev (10):
      sunrpc: assign PDE->data before gluing PDE into /proc tree
      netfilter: assign PDE->data before gluing PDE into /proc tree
      net: assign PDE->data before gluing PDE into /proc tree
      ipv6: assign PDE->data before gluing PDE into /proc tree
      atm: assign PDE->data before gluing PDE into /proc tree
      vlan: assign PDE->data before gluing PDE into /proc tree
      ipv4: assign PDE->data before gluing PDE into /proc tree
      netfilter: assign PDE->fops before gluing PDE into /proc tree
      netfilter: assign PDE->data before gluing PDE into /proc tree
      netns: assign PDE->data before gluing entry into /proc tree

Guy Cohen (1):
      iwlwifi: fix current channel is not scanned

Harvey Harrison (6):
      mac80211: incorrect shift direction
      net: fix returning void-valued expression warnings
      irda: use get_unaligned_* helpers
      bluetooth: use get/put_unaligned_* helpers
      net: use get/put_unaligned_* helpers
      dccp: ccid2.c, ccid3.c use clamp(), clamp_t()

Holger Schurig (1):
      libertas: fix use-before-check violation

Ilpo J=E4rvinen (1):
      net: Add missing braces to multi-statement if()s

Ivo van Doorn (2):
      rt2x00: Don't enable short preamble for 1MBs
      rt2x00: Fix quality/activity led handling

Johannes Berg (3):
      mac80211: assign conf.beacon_control for mesh
      mac80211: don't allow invalid WDS peer addresses
      mac80211: insert WDS peer after adding interface

Kirill A. Shutemov (1):
      Make linux/wireless.h be able to compile

Luis Carlos Cobo (1):
      mac80211: use 4-byte mesh sequence number

Matt Carlson (5):
      tg3: Use constant 500KHz MI clock on adapters with a CPMU
      tg3: Fix 5761 NVRAM sizes
      tg3: Fix ethtool loopback test for 5761 BX devices
      tg3: Add link state reporting to UMP firmware
      tg3: Update version to 3.92

Michael Buesch (2):
      b43: Fix dual-PHY devices
      b43: Fix some TX/RX locking issues

Michael Chan (6):
      bnx2: Refine remote PHY locking.
      bnx2: Fix remote PHY initial link state.
      bnx2: Fix register test on 5709.
      bnx2: Zero out context memory for 5709.
      bnx2: Update RV2P firmware for 5709.
      bnx2: Update version to 1.7.5.

Mike Travis (1):
      net: remove NR_CPUS arrays in net/core/dev.c

Pavel Machek (1):
      hci_usb.h: fix hard-to-trigger race

Stephen Hemminger (1):
      bridge: forwarding table information for >256 devices

 drivers/bluetooth/hci_usb.h                 |   21 +-
 drivers/net/8390.c                          |    2 +-
 drivers/net/bnx2.c                          |   43 ++-
 drivers/net/bnx2_fw2.h                      |  502 ++++++++++++++-----=
--------
 drivers/net/tg3.c                           |  149 ++++++--
 drivers/net/tg3.h                           |   15 +-
 drivers/net/wireless/b43/b43.h              |    4 +
 drivers/net/wireless/b43/main.c             |   51 ++-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   29 +--
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   26 +-
 drivers/net/wireless/libertas/scan.c        |    3 +-
 drivers/net/wireless/rt2x00/rt2400pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c     |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    2 +
 drivers/net/wireless/rt2x00/rt2x00leds.c    |   15 +
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    6 +
 drivers/net/wireless/rt2x00/rt61pci.c       |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    2 +-
 drivers/net/xen-netfront.c                  |    2 +-
 fs/proc/generic.c                           |   17 +
 fs/proc/proc_net.c                          |   11 -
 include/linux/ieee80211.h                   |    2 +-
 include/linux/if_bridge.h                   |    4 +-
 include/linux/wireless.h                    |    7 +-
 net/8021q/vlanproc.c                        |    7 +-
 net/atm/proc.c                              |    6 +-
 net/bluetooth/bnep/core.c                   |    8 +-
 net/bluetooth/hci_event.c                   |    9 +-
 net/bluetooth/hci_sock.c                    |    2 +-
 net/bluetooth/l2cap.c                       |    2 +-
 net/bridge/br_fdb.c                         |    4 +
 net/bridge/br_stp_bpdu.c                    |    4 +-
 net/core/dev.c                              |   19 +-
 net/core/filter.c                           |    4 +-
 net/core/neighbour.c                        |    5 +-
 net/core/net-sysfs.c                        |    7 +-
 net/core/net-sysfs.h                        |    2 +-
 net/core/pktgen.c                           |   12 +-
 net/core/sock.c                             |    3 +-
 net/dccp/ccids/ccid2.c                      |    2 +-
 net/dccp/ccids/ccid3.c                      |    4 +-
 net/ipv4/cipso_ipv4.c                       |   18 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c          |    6 +-
 net/ipv4/tcp_hybla.c                        |    6 +-
 net/ipv4/tcp_input.c                        |   18 +-
 net/ipv4/tcp_ipv4.c                         |   10 +-
 net/ipv4/tcp_vegas.c                        |    6 +-
 net/ipv4/tcp_veno.c                         |    6 +-
 net/ipv4/udp.c                              |    7 +-
 net/ipv6/proc.c                             |    6 +-
 net/ipv6/reassembly.c                       |    4 +-
 net/irda/iriap.c                            |    8 +-
 net/mac80211/ieee80211_i.h                  |    2 +-
 net/mac80211/main.c                         |   47 ++-
 net/mac80211/mesh.c                         |   17 +-
 net/mac80211/mesh.h                         |    2 +-
 net/mac80211/tkip.c                         |    6 +-
 net/netfilter/nf_conntrack_standalone.c     |    6 +-
 net/netfilter/x_tables.c                    |   13 +-
 net/netfilter/xt_hashlimit.c                |   12 +-
 net/rose/rose_route.c                       |    8 +-
 net/rxrpc/ar-transport.c                    |    3 +-
 net/sched/sch_generic.c                     |    1 +
 net/sunrpc/cache.c                          |   15 +-
 net/sunrpc/stats.c                          |    8 +-
 net/sysctl_net.c                            |    2 +-
 69 files changed, 704 insertions(+), 560 deletions(-)
