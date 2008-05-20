From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 20 May 2008 16:11:03 -0700 (PDT)
Message-ID: <20080520.161103.200997997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752680AbYETXLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 19:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A lot of small stuff:

1) Pull in wireless bug fixes from John Linville.

2) Kill CVS keywords from ATM code, from Adrian Bunk and ACK'd by
   ATM maintainer.

3) skb->truesize not maintained properly my l2tp code, fix from
   James Chapman.

4) IPSEC can crash on output path due to wrong output routine
   usage, fix from Herbert Xu.

5) Fix pktgen shutdown race, from Denis Lunev.

6) Zap cli/sti from hysdn driver, and no longer mark broken on SMP.
   From Mark Asselstine and Andrew Morton.

7) cls_api returns incorrect error code, from Patrick McHardy.

8) linux/in6.h needs unifdef-y treatment, from Robert Day

9) atm_tcp.h and atm.h need to include the correct headers in order
   to be used properly in userspace, from Mike Frysinger.

10) Fix handling of network device rename conflicts, from Stephen
    Hemminger.

11) Route lifetime and neighbour reachability bug fixes in ipv6
    from YOSHIFUJI Hideaki.

12) Layered VLAN devices don't handle notifications properly, fix from
    Patrick McHardy.

13) Provide a way for hardware devices to indicate that when VLAN is
    enabled, they can still offload checksumming et al.  Also from
    Patrick McHardy.

Please pull, thanks a lot!

The following changes since commit 8f40f672e6bb071812f61bfbd30efc3fc1263ad1:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../ericvh/v9fs

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Association with 11n hidden ssid ap.

Adrian Bunk (1):
      drivers/atm/: remove CVS keywords

Alan Cox (1):
      iphase: Fix 64bit warning.

Andrew Morton (1):
      hysdn: No longer broken on SMP.

Brian Cavagnolo (1):
      libertas: fix command timeout after firmware failure

David S. Miller (1):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

David Woodhouse (1):
      net: Fix call to ->change_rx_flags(dev, IFF_MULTICAST) in dev_change_flags()

Denis V. Lunev (1):
      pktgen: make sure that pktgen_thread_worker has been executed

Herbert Xu (1):
      ipsec: Use the correct ip_local_out function

Ivo van Doorn (1):
      mac80211: Add RTNL version of ieee80211_iterate_active_interfaces

James Chapman (1):
      l2tp: avoid skb truesize bug if headroom is increased

Marcin Slusarz (1):
      isdn/capi: Return proper errnos on module init.

Mark Asselstine (1):
      hysdn: Remove cli()/sti() calls.

Masakazu Mokuno (1):
      wireless: Create 'device' symlink in sysfs

Mathieu Chouquet-Stringer (1):
      hostap: fix "registers" registration in procfs

Mike Frysinger (1):
      atm: Cleanup atm_tcp.h and atm.h for userspace.

Patrick McHardy (3):
      net_sched: cls_api: fix return value for non-existant classifiers
      vlan: Correctly handle device notifications for layered VLAN devices
      [VLAN]: Propagate selected feature bits to VLAN devices

Robert P. J. Day (1):
      ipv6: Move <linux/in6.h> from header-y to unifdef-y.

Roel Kluin (1):
      wireless, airo: waitbusy() won't delay

Stephen Hemminger (3):
      net: handle errors from device_rename
      sysfs: remove error messages for -EEXIST case
      bonding: handle case of device named bonding_master

YOSHIFUJI Hideaki (4):
      ndisc: Add missing strategies for per-device retrans timer/reachable time settings.
      ipv6 addrconf: Fix route lifetime setting in corner case.
      ipv6 route: Fix lifetime in netlink.
      ipv6 addrconf: Allow infinite prefix lifetime.

 drivers/atm/fore200e.h                  |    1 -
 drivers/atm/fore200e_mkfirm.c           |    2 -
 drivers/atm/he.h                        |    2 -
 drivers/atm/idt77252.c                  |    7 ---
 drivers/atm/idt77252.h                  |    4 --
 drivers/atm/iphase.h                    |    3 +-
 drivers/atm/nicstarmac.copyright        |    2 +-
 drivers/base/core.c                     |    8 +--
 drivers/isdn/capi/capiutil.c            |    6 +-
 drivers/isdn/hysdn/Kconfig              |    2 +-
 drivers/isdn/hysdn/boardergo.c          |   14 ++----
 drivers/net/bonding/bond_sysfs.c        |   12 ++++-
 drivers/net/pppol2tp.c                  |   13 +++--
 drivers/net/wireless/airo.c             |    3 +-
 drivers/net/wireless/hostap/hostap_hw.c |    9 ++--
 drivers/net/wireless/ipw2200.c          |    1 +
 drivers/net/wireless/libertas/main.c    |    2 +
 fs/sysfs/dir.c                          |    6 +--
 include/linux/Kbuild                    |    2 +-
 include/linux/atm.h                     |    7 +--
 include/linux/atm_tcp.h                 |   12 ++---
 include/linux/netdevice.h               |    6 ++-
 include/net/mac80211.h                  |   25 +++++++++-
 include/net/ndisc.h                     |    4 ++
 net/8021q/vlan.c                        |   34 +++++++++++++-
 net/8021q/vlan.h                        |    2 +
 net/8021q/vlan_dev.c                    |    5 ++
 net/core/dev.c                          |    8 +++-
 net/core/pktgen.c                       |    4 ++
 net/ipv4/route.c                        |    2 +-
 net/ipv6/addrconf.c                     |   75 ++++++++++++++++++++----------
 net/ipv6/ndisc.c                        |    8 ++--
 net/ipv6/route.c                        |   12 +++--
 net/mac80211/mlme.c                     |   14 ++----
 net/mac80211/util.c                     |   37 +++++++++++++++-
 net/sched/cls_api.c                     |    2 +-
 36 files changed, 235 insertions(+), 121 deletions(-)
