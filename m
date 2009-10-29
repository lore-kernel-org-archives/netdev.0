From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 29 Oct 2009 07:17:09 -0700 (PDT)
Message-ID: <20091029.071709.120520760.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754342AbZJ2OQq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 10:16:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Bonding stores "ioctl" operations pointer in a function local
   variable which is accidently 'static', oops.  Fix from Jiri Bohac.

2) Bond hash on transmit should use source MAC, using the bonding
   device address is not correct.  Fix from Jasper Spaans

3) PACKET_TX_RING enforced size limit is bogus, from Gabor Gombas.

4) Three netxen driver fixes from Amit Kumar Salecha and Dhananjay Phad=
ke.

5) Memory leaks on interface down in igb/ixgbe/igbvf, from Alexander Du=
yck

6) Fix circular locking deadlock in ISDN, from Xiaotian Feng.

7) Arjan tidied up the WARN_ON added to tcp_recvmsg() so that
   kerneloops will get better information.

8) myri10ge reports bogus port types to ethtool, fix from Brice Goglin.

9) Build failure fix in au1000_eth, missing capability.h include,
   from Manuel Lauss.

10) ifb driver needs to use dev_get_by_index() instead of
    __dev_get_by_index() since it holds neither the RTNL semaphore
    not the dev_base_lock.  Fix from Eric Dumazet.

11) r8169 hang fix for RTL8110SC rev d chips, from Simon Wunderlich.

12) DM9000B chip revision value is wrong, fix from Ben Dooks.

13) pktgen can leak some kernel memory, fix from Eric Dumazet.

14) e1000e bug fixes from Bruce Allan.

15) Fix flush/close races in PPPOE, particularly triggered by
    namespaces, from Michal Ostrowski.

16) sh_eth needs to include asm/cacheflush.h to build properly, fix
    from Nobuhiro Iwamatsu.

17) bnx2 BNX2_L2CTX_STATUSB_NUM defines are wrong with current
    firmware, fix from Michael Chan.

18) sfc driver can leave ip_summed not set properly in some cases,
    fix from Ben Hutchings.

19) virtio_net data corruption fix during OOM from Michael S. Tsirkin.

20) raw sockets using the hdrinc option can end up crashing because
    the IHL is bogus and would go past the length of the user supplied
    buffer.  Fix from Neil Horman.

21) Fix for EEH and firmware mailbox timeouts in qlge driver from Ron
    Mercer.

22) Add a missing device ID to dm9601 USB net driver, thanks to Janusz
    Krzysztofik.

23) Assorted one-liners and other small wireless fixes via John
    Linville.  Some were fixed during the kernel summit and those
    commits are marked as such :-)

Please pull, thanks!

The following changes since commit 964fe080d94db82a3268443e9b9ece4c6024=
6414:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../rusty/linux-2.6-for-linus

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (3):
      igb: fix memory leak when setting ring size while interface is do=
wn
      ixgbe: fix memory leak when resizing rings while interface is dow=
n
      igbvf: fix memory leak when ring size changed while interface dow=
n

Amit Kumar Salecha (1):
      netxen: fix tx timeout handling on firmware hang

Andrey Yurovsky (1):
      mac80211: trivial: fix spelling in mesh_hwmp

Arjan van de Ven (1):
      net: use WARN() for the WARN_ON in commit b6b39e8f3fbbb

Bartlomiej Zolnierkiewicz (1):
      MAINTAINERS: rt2x00 list is moderated

Ben Dooks (1):
      DM9000: Fix revision ID for DM9000B

Ben Hutchings (1):
      sfc: Set ip_summed correctly for page buffers passed to GRO

Benoit PAPILLAULT (1):
      rt2x00: Fix crypto in TX frame for rt2800usb

Bj=F6rn Smedman (1):
      mac80211: fix for incorrect sequence number on hostapd injected f=
rames

Brice Goglin (1):
      myri10ge: improve port type reporting in ethtool

Bruce Allan (6):
      e1000e: reset the PHY on 82577/82578 when going to Sx
      e1000e: clear PHY wakeup bit after LCD reset on 82577/82578
      e1000e: increase swflag acquisition timeout for ICHx/PCH
      e1000e: 82577/82578 requires a different method to configure LPLU
      e1000e: separate mutex usage between NVM and PHY/CSR register for=
 ICHx/PCH
      e1000e: allow for swflag to be held over consecutive PHY accesses

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Dhananjay Phadke (2):
      netxen: fix i2c init
      netxen: avoid undue board config check

Eric Dumazet (2):
      ifb: should not use __dev_get_by_index() without locks
      pktgen: Dont leak kernel memory

Gabor Gombas (1):
      net: Fix 'Re: PACKET_TX_RING: packet size is too long'

Holger Schurig (1):
      libertas spi: fix sparse errors

Janusz Krzysztofik (1):
      netdev: usb: dm9601.c can drive a device not supported yet, add s=
upport for it

Jasper Spaans (1):
      bonding: Modify hash transmit policies to use the packet's source=
 MAC address

Jiri Bohac (1):
      bonding: fix a race condition in calls to slave MII ioctls

Johannes Berg (2):
      mac80211: keep auth state when assoc fails
      cfg80211: sme: deauthenticate on assoc failure

Larry Finger (1):
      b43: Fix Bugzilla #14181 and the bug from the previous 'fix'

Manuel Lauss (1):
      net: au1000_eth: add missing capability.h

Michael Chan (1):
      cnic: Fix L2CTX_STATUSB_NUM offset in context memory.

Michael S. Tsirkin (1):
      virtio-net: fix data corruption with OOM

Michal Ostrowski (1):
      PPPoE: Fix flush/close races.

Miguel Boton (1):
      b43: add 'struct b43_wl' missing declaration

Neil Horman (1):
      AF_RAW: Augment raw_send_hdrinc to expand skb to fit iphdr->ihl (=
v2)

Nobuhiro Iwamatsu (1):
      sh_eth: Add asm/cacheflush.h

Reinette Chatre (1):
      mac80211: fix ibss joining

Roel Kluin (1):
      airo: Reorder tests, check bounds before element

Ron Mercer (2):
      qlge: Fix EEH handling.
      qlge: Fix firmware mailbox command timeout.

Simon Wunderlich (1):
      r8169: fix Ethernet Hangup for RTL8110SC rev d

Xiaotian Feng (1):
      isdn: fix possible circular locking dependency

 MAINTAINERS                             |    2 +-
 drivers/isdn/i4l/isdn_net.h             |    6 +-
 drivers/net/au1000_eth.c                |    1 +
 drivers/net/bnx2.h                      |    9 +-
 drivers/net/bonding/bond_main.c         |   10 +-
 drivers/net/cnic.c                      |    6 +-
 drivers/net/dm9000.h                    |    2 +-
 drivers/net/e1000e/e1000.h              |   12 +
 drivers/net/e1000e/hw.h                 |    2 +
 drivers/net/e1000e/ich8lan.c            |  150 ++++++++---
 drivers/net/e1000e/phy.c                |  469 +++++++++++++++++++++--=
-------
 drivers/net/ifb.c                       |    3 +-
 drivers/net/igb/igb_ethtool.c           |   35 ++-
 drivers/net/igbvf/ethtool.c             |   30 ++-
 drivers/net/ixgbe/ixgbe_ethtool.c       |   22 +-
 drivers/net/myri10ge/myri10ge.c         |   17 +-
 drivers/net/netxen/netxen_nic_hdr.h     |    1 +
 drivers/net/netxen/netxen_nic_hw.c      |   14 +-
 drivers/net/netxen/netxen_nic_init.c    |    8 +-
 drivers/net/netxen/netxen_nic_main.c    |    1 +
 drivers/net/pppoe.c                     |  129 +++++----
 drivers/net/qlge/qlge.h                 |    1 +
 drivers/net/qlge/qlge_main.c            |   78 ++++--
 drivers/net/qlge/qlge_mpi.c             |   23 +-
 drivers/net/r8169.c                     |   13 +-
 drivers/net/sfc/rx.c                    |    9 +-
 drivers/net/sh_eth.c                    |    1 +
 drivers/net/usb/dm9601.c                |    4 +
 drivers/net/virtio_net.c                |   14 +-
 drivers/net/wireless/airo.c             |    5 +-
 drivers/net/wireless/b43/leds.h         |    1 +
 drivers/net/wireless/b43/main.c         |    1 -
 drivers/net/wireless/b43/rfkill.c       |    3 +-
 drivers/net/wireless/libertas/if_spi.c  |   10 +-
 drivers/net/wireless/rt2x00/rt2800usb.c |    2 +-
 net/core/pktgen.c                       |   15 +-
 net/ipv4/raw.c                          |   24 ++-
 net/ipv4/tcp.c                          |    6 +-
 net/mac80211/ibss.c                     |    6 +-
 net/mac80211/mesh_hwmp.c                |    2 +-
 net/mac80211/mlme.c                     |    3 +-
 net/mac80211/tx.c                       |    2 +-
 net/packet/af_packet.c                  |    5 +-
 net/wireless/core.h                     |    1 +
 net/wireless/mlme.c                     |    9 +
 net/wireless/sme.c                      |   21 ++-
 46 files changed, 796 insertions(+), 392 deletions(-)
