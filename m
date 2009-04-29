From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 28 Apr 2009 23:08:37 -0700 (PDT)
Message-ID: <20090428.230837.116369337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53103
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755760AbZD2GIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 02:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hopefully we can chip away at a couple regression list entries
with this:

1) Fix kexec with e100.

2) Fix OOPS on veth destructor.

3) The infamous x_tables locking fix.

4) Bluetooth fixes via Marcel Holtmann.

5) ISDN documentation updates via Karsten Keil.

6) IPSEC rule hash values incorrectly calculated for temporary SAs.

7) An inet datagram socket blocked on receive wakes up on every
   transmit, due to the global memory accounting added a few releases
   ago, which hurts performance quite a bit.  Fix this by using the
   keyed wakeup facility.
   
8) On machines with absurd amounts of memory, the ipv4 routing cache
   hash table gets an equally absurd size.

Please pull, thanks a lot!

The following changes since commit 27b1833279995e7c290a40cac4ef36ccea7e9283:
  Tim Abbott (1):
        Remove unused support code for refok sections.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      net: Fix LL_MAX_HEADER for CONFIG_TR_MODULE

Anton Blanchard (1):
      ipv4: Limit size of route cache hash table

Ayaz Abdulla (1):
      forcedeth: tx timeout fix

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Eric Dumazet (1):
      net: Avoid extra wakeups of threads blocked in wait_for_packet()

Jan Engelhardt (1):
      netfilter: xt_recent: fix stack overread in compat code

Jay Vosburgh (1):
      vlan: update vlan carrier state for admin up/down

Karsten Keil (1):
      Add reference to CAPI 2.0 standard

Laszlo Attila Toth (1):
      netfilter: Kconfig: TProxy doesn't depend on NF_CONNTRACK

Marcel Holtmann (2):
      Bluetooth: Add different pairing timeout for Legacy Pairing
      Bluetooth: Fix connection establishment with low security requirement

Mike Rapoport (1):
      net: Fix typo in net_device_ops description.

Nicolas Dichtel (1):
      xfrm: wrong hash value for temporary SA

Pablo Neira Ayuso (1):
      netfilter: nf_ct_dccp: add missing role attributes for DCCP

Patrick McHardy (1):
      netfilter: nf_ct_dccp/udplite: fix protocol registration error

Roger Quadros (1):
      Bluetooth: Ensure that HCI sysfs add/del is preempt safe

Stephen Hemminger (2):
      veth: prevent oops caused by netdev destructor
      netfilter: revised locking for x_tables

Thadeu Lima de Souza Cascardo (1):
      e100: do not go D3 in shutdown unless system is powering off

Tilman Schmidt (2):
      update Documentation/isdn/00-INDEX
      Documentation/isdn/INTERFACE.CAPI

Waskiewicz Jr, Peter P (1):
      ixgbe: Fix WoL functionality for 82599 KX4 devices

Yevgeny Petrilin (2):
      mlx4_en: Fix cleanup flow on cq activation
      mlx4_en: Handle page allocation failure during receive

hummerbliss@gmail.com (1):
      netfilter: bridge: allow fragmentation of VLAN packets traversing a bridge

 Documentation/isdn/00-INDEX                   |   17 ++-
 Documentation/isdn/INTERFACE.CAPI             |  213 +++++++++++++++++++++++++
 drivers/isdn/capi/kcapi.c                     |  171 ++++++++++++++++++++
 drivers/net/e100.c                            |   30 +++-
 drivers/net/forcedeth.c                       |   31 +++--
 drivers/net/ixgbe/ixgbe_common.c              |   51 +------
 drivers/net/ixgbe/ixgbe_main.c                |   10 +-
 drivers/net/mlx4/en_netdev.c                  |    2 +-
 drivers/net/mlx4/en_rx.c                      |    4 +
 drivers/net/veth.c                            |   41 ++---
 include/linux/netdevice.h                     |    4 +-
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/linux/netfilter/x_tables.h            |   73 ++++++++-
 include/linux/wait.h                          |    6 +-
 include/net/bluetooth/hci.h                   |    1 +
 include/net/bluetooth/hci_core.h              |    8 +-
 net/8021q/vlan.c                              |    2 +
 net/8021q/vlan_dev.c                          |    5 +
 net/bluetooth/hci_conn.c                      |   10 +-
 net/bluetooth/hci_event.c                     |   36 ++++-
 net/bluetooth/hci_sysfs.c                     |   37 ++---
 net/bridge/br_netfilter.c                     |   10 +-
 net/core/datagram.c                           |   14 ++-
 net/ipv4/netfilter/arp_tables.c               |  125 ++++----------
 net/ipv4/netfilter/ip_tables.c                |  126 ++++-----------
 net/ipv4/route.c                              |    2 +-
 net/ipv6/netfilter/ip6_tables.c               |  123 +++++----------
 net/netfilter/Kconfig                         |    4 +-
 net/netfilter/nf_conntrack_proto_dccp.c       |   16 ++-
 net/netfilter/nf_conntrack_proto_udplite.c    |    1 +
 net/netfilter/x_tables.c                      |   53 ++++---
 net/netfilter/xt_recent.c                     |    9 +-
 net/xfrm/xfrm_state.c                         |    6 +-
 33 files changed, 795 insertions(+), 447 deletions(-)
 create mode 100644 Documentation/isdn/INTERFACE.CAPI
