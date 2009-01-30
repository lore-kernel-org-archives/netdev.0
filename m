From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 30 Jan 2009 00:20:46 -0800 (PST)
Message-ID: <20090130.002046.130715237.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33379
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752296AbZA3IUt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 03:20:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More bug fixes, highlights:

1) IP-Config can loop forever retrying due to a bug in how
   the retry counter is initialized.  Fix from Benjamin Zores.

2) iSCSI OOPS fixes from Herbert Xu and Shyam Iyer.

3) Several IPV6 multicast routing bug fixes from Thomas Goff.

4) Wireless bug fixes via John Linville.

5) E1000 shared interrupt handling fix from Jesse Brandeburg.

6) UDP port bind performance regression fix from Eric Dumazet.
   This came from the port randomization improvements.

7) TCP URG handling fix for splice() from Dimitris Michailidis.

8) Missing compat support for a few TUN device ioctls.

Please pull, thanks a lot!

The following changes since commit 5376071069ec8a7e6a8112beab16fc24f513=
9475:
  Linus Torvalds (1):
        Merge master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anton Vorontsov (1):
      gianfar: Fix Wake-on-LAN support

Benjamin Zores (1):
      ipv4: fix infinite retry loop in IP-Config

Bob Copeland (1):
      ath5k: fix locking in ath5k_config

Daniel Marjam=E4ki (1):
      netxen: fix memory leak in drivers/net/netxen_nic_init.c

David S. Miller (3):
      ipv6: Make mc_forwarding sysctl read-only.
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      tun: Add some missing TUN compat ioctl translations.

Dhananjay Phadke (1):
      netxen: revert jumbo ringsize

Dimitris Michailidis (1):
      tcp: Fix length tcp_splice_data_recv passes to skb_splice_bits.

Eric Dumazet (2):
      udp: optimize bind(0) if many ports are in use
      net: wrong test in inet_ehash_locks_alloc()

Haiying Wang (1):
      ucc_geth: Change uec phy id to the same format as gianfar's

Herbert Xu (1):
      net: Fix frag_list handling in skb_seq_read

Inaky Perez-Gonzalez (1):
      wimax: fix build issue when debugfs is disabled

Ira W. Snyder (1):
      virtio_net: use correct accessors for scatterlists

Jesse Brandeburg (1):
      e1000: fix bug with shared interrupt during reset

Jiri Pirko (1):
      net: fix xfrm reverse flow lookup for icmp6

Johannes Berg (1):
      mac80211: remove Michael Wu as maintainer

Larry Finger (1):
      rtl8187: Fix error in setting OFDM power settings for RTL8187L

Luis R. Rodriguez (2):
      cfg80211: Fix sanity check on 5 GHz when processing country IE
      cfg80211: print correct intersected regulatory domain

Manish Katiyar (1):
      r6040: Remove unused variable pdev from drivers/net/r6040.c

Philippe De Muyter (1):
      tulip: fix 21142 with 10Mbps without negotiation

Roel Kluin (2):
      smsc911x: timeout reaches -1
      drivers/net/skfp: if !capable(CAP_NET_ADMIN): inverted logic

Shyam Iyer (1):
      net: Fix OOPS in skb_seq_read().

Stephen Hemminger (1):
      net: update documentation ip aliases

Steve Glendinning (1):
      smsc9420: fix interrupt signalling test failures

Thomas Goff (1):
      IPv6: Fix multicast routing bugs.

Zhu, Yi (1):
      iwlwifi: fix kernel oops when ucode DMA memory allocation failure

 Documentation/networking/alias.txt             |   25 +++--------
 MAINTAINERS                                    |    2 -
 drivers/net/e1000/e1000_main.c                 |    4 +-
 drivers/net/gianfar_mii.c                      |    2 +
 drivers/net/netxen/netxen_nic.h                |    2 +-
 drivers/net/netxen/netxen_nic_init.c           |    4 +-
 drivers/net/r6040.c                            |    1 -
 drivers/net/skfp/skfddi.c                      |    4 +-
 drivers/net/smsc911x.c                         |    2 +-
 drivers/net/smsc9420.c                         |    3 +-
 drivers/net/tulip/21142.c                      |   23 ++++++++--
 drivers/net/ucc_geth.c                         |   20 ++++++++-
 drivers/net/ucc_geth.h                         |    2 +
 drivers/net/ucc_geth_mii.c                     |   12 +++++-
 drivers/net/ucc_geth_mii.h                     |    1 +
 drivers/net/virtio_net.c                       |    6 +-
 drivers/net/wimax/i2400m/debugfs.c             |   14 ------
 drivers/net/wimax/i2400m/driver.c              |   16 +++++++
 drivers/net/wireless/ath5k/base.c              |   10 ++++-
 drivers/net/wireless/iwlwifi/iwl-agn.c         |    4 ++
 drivers/net/wireless/rtl818x/rtl8187_rtl8225.c |   10 +++-
 fs/compat_ioctl.c                              |    7 +++
 include/net/inet_hashtables.h                  |    2 +-
 net/core/skbuff.c                              |   15 +++---
 net/ipv4/ipconfig.c                            |    6 +-
 net/ipv4/tcp.c                                 |    3 +-
 net/ipv4/udp.c                                 |   55 ++++++++++++++++=
+-------
 net/ipv6/addrconf.c                            |    2 +-
 net/ipv6/icmp.c                                |    4 +-
 net/ipv6/ip6_input.c                           |    2 +-
 net/ipv6/ip6mr.c                               |   23 ++++++++--
 net/ipv6/route.c                               |    2 +-
 net/wimax/debugfs.c                            |   11 -----
 net/wimax/stack.c                              |   13 ++++++
 net/wireless/reg.c                             |   32 +++++++++-----
 35 files changed, 225 insertions(+), 119 deletions(-)
