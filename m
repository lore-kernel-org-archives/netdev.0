From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-04-29
Date: Sun, 29 Apr 2012 10:57:32 +0200
Message-ID: <1335689867-8017-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello David,

this is the new version of my last pull request (issued on 2012-04-25).
This patchset is intended for net-next/linux-3.5.

Since last series I only removed the biggest_unsigned_int() macro.

Let me know if there is any other problem.

Thank you,
	Antonio

===============================================================

The following changes since commit 7a2a66a0ac1cf93d30869c4ecbfc71a2fda19397:

  Add linux-next specific files for 20120423 (2012-04-23 16:58:43 +1000)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 3ad345e2521ef41500cc0890a717656b975c4321:

  batman-adv: split neigh_new function into generic and batman iv specific parts (2012-04-29 10:50:10 +0200)

----------------------------------------------------------------
Included changes:

* a new feature has been introduced: D.A.T. (Distributed ARP Table). It is a
  mechanism based on DHT theory that creates a distributed (mesh network wide)
  ARP cache in order to speed up ARP resolutions in sparse wireless mesh
  networks.
* in order to satisfy DAT requirements a new unicast packet type, namely
  UNICAST_4ADDR, has been introduced. Backward compatibility has been kept: not
  updated nodes will simply drop the packet and ignore DAT mechanism.
* minor fixes and cleanups
* minor routing protocol API cleanups

----------------------------------------------------------------
Antonio Quartulli (9):
      batman-adv: add UNICAST_4ADDR packet type
      batman-adv: add a new log level for DAT debugging
      batman-adv: add biggest_unsigned_int(x) macro
      batman-adv: Distributed ARP Table - create DHT helper functions
      batman-adv: Distributed ARP Table - add ARP parsing functions
      batman-adv: Distributed ARP Table - add snooping functions for ARP messages
      batman-adv: Distributed ARP Table - increase default soft_iface ARP table timeout
      batman-adv: Distributed ARP Table - add compile option
      batman-adv: fix wrong dhcp option list browsing

Marek Lindner (6):
      batman-adv: introduce is_single_hop_neigh variable to increase readability
      batman-adv: introduce packet type handler array for incoming packets
      batman-adv: register batman ogm receive function during protocol init
      batman-adv: rename last_valid to last_seen
      batman-adv: replace HZ calculations with jiffies_to_msecs()
      batman-adv: split neigh_new function into generic and batman iv specific parts

 Documentation/networking/batman-adv.txt |    3 +-
 net/batman-adv/Kconfig                  |   10 +
 net/batman-adv/Makefile                 |    1 +
 net/batman-adv/bat_debugfs.c            |    4 +-
 net/batman-adv/bat_iv_ogm.c             |   95 +++--
 net/batman-adv/bat_sysfs.c              |    2 +-
 net/batman-adv/distributed-arp-table.c  |  605 +++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h  |  140 +++++++
 net/batman-adv/gateway_client.c         |    6 +-
 net/batman-adv/hard-interface.c         |  116 +-----
 net/batman-adv/main.c                   |  124 ++++++-
 net/batman-adv/main.h                   |   21 +-
 net/batman-adv/originator.c             |   52 +--
 net/batman-adv/originator.h             |    6 +-
 net/batman-adv/packet.h                 |   30 +-
 net/batman-adv/routing.c                |   30 +-
 net/batman-adv/routing.h                |    4 +-
 net/batman-adv/send.c                   |    6 +-
 net/batman-adv/soft-interface.c         |   17 +-
 net/batman-adv/types.h                  |   33 +-
 net/batman-adv/unicast.c                |  102 +++++-
 net/batman-adv/unicast.h                |   21 +-
 22 files changed, 1202 insertions(+), 226 deletions(-)
 create mode 100644 net/batman-adv/distributed-arp-table.c
 create mode 100644 net/batman-adv/distributed-arp-table.h
