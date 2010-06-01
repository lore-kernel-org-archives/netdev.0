From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 01 Jun 2010 01:35:27 -0700 (PDT)
Message-ID: <20100601.013527.235698453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44449
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753607Ab0FAIfR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 04:35:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) OF device conversions broke greth driver build.

2) mpc5xxx_can.c driver build fix from Anatolij Gustschin.

3) Mobile IPV6 broken by output interface routing change, fix
   from Brian Haley.

4) ar9170usb use after free fix from Christian Lamparter.

5) Missing unlock on error in be2net from Dan Carpenter.

6) hdr.timeout accesses in be2net need to be little-endian, fix
   from Sathya Perla.

7) Busted connected socket list locking in Phonet, fix from
   R=E9mi Denis-Courmont.

8) Two netfilter fixes via Patrick McHardy:
   a) Accidental double-allocation in xt_register_table fixes
      by Xiaotian Feng
   b) xtables stackptr needs to be percpu, from Eric Dumazet

9) TCP compile fix with debugging options enabled, from Joe Perches.

10) Missing unlock and GFP_KERNEL with lock held fix in ISDN
    from Julia Lawall.

11) Two changes from Eric Dumazet that attempt to cure sock_queue_err_s=
kb()'s
    erroneous modifications ->sk_forward_alloc without locking.

12) ksz884x driver returns wrong type from ->ndo_start_xmit() and
    is missing validate_addr in netdev_ops.  From Denis Kirjanov.

13) Wireless bug fixes from John Linville and co.

Please pull, thanks a lot!

The following changes since commit 67a3e12b05e055c0415c556a315a3d3eb637=
e29e:
  Linus Torvalds (1):
        Linux 2.6.35-rc1

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Anatolij Gustschin (1):
      can: mpc5xxx_can.c: Fix build failure

Brian Haley (1):
      IPv6: fix Mobile IPv6 regression

Changli Gao (1):
      skb: make skb_recycle_check() return a bool value

Christian Lamparter (1):
      ar9170usb: fix read from freed driver context

Christoph Fritz (1):
      ssb: fix NULL ptr deref when pcihost_wrapper is used

Dan Carpenter (3):
      be2net: add unlock on error path
      be2net: remove superfluous externs
      caif: unlock on error path in cfserl_receive()

David S. Miller (4):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      greth: Fix build after OF device conversions.
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

Denis Kirjanov (2):
      ksz884x: convert to netdev_tx_t
      ksz884x: Add missing validate_addr hook

Eric Dumazet (3):
      net: fix sk_forward_alloc corruptions
      netfilter: xtables: stackptr should be percpu
      net: sock_queue_err_skb() dont mess with sk_forward_alloc

Joe Perches (1):
      net/ipv4/tcp_input.c: fix compilation breakage when FASTRETRANS_D=
EBUG > 1

Johannes Berg (1):
      mac80211: make a function static

John W. Linville (1):
      Revert "rt2x00: Fix rt2800usb TX descriptor writing."

Julia Lawall (3):
      drivers/isdn/hardware/mISDN: Add missing spin_unlock
      net/rds: Add missing mutex_unlock
      drivers/isdn/hardware/mISDN: Use GFP_ATOMIC when a lock is held

Justin P. Mattock (1):
      ath9k: Fix ath_print in xmit for hardware reset.

Mark Ware (1):
      fs_enet: Adjust BDs after tx error

Michael S. Tsirkin (1):
      virtio-net: pass gfp to add_buf

Prarit Bhargava (1):
      libertas: fix uninitialized variable warning

R=E9mi Denis-Courmont (1):
      Phonet: listening socket lock protects the connected socket list

Sathya Perla (1):
      be2net: convert hdr.timeout in be_cmd_loopback_test() to le32

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in the way "bf_tx_aborted" of struct ath_buf is us=
ed

Xiaotian Feng (1):
      netfilter: don't xt_jumpstack_alloc twice in xt_register_table

 drivers/isdn/hardware/mISDN/hfcsusb.c   |    4 ++-
 drivers/isdn/hardware/mISDN/netjet.c    |    4 +-
 drivers/net/benet/be_cmds.c             |   13 +++++---
 drivers/net/can/mscan/mpc5xxx_can.c     |   10 +++---
 drivers/net/fs_enet/mac-fcc.c           |   49 +++++++++++++++++++++++=
++++----
 drivers/net/greth.c                     |   11 +++----
 drivers/net/ksz884x.c                   |    3 +-
 drivers/net/virtio_net.c                |    8 ++--
 drivers/net/wireless/ath/ar9170/usb.c   |   14 +++++++-
 drivers/net/wireless/ath/ath9k/xmit.c   |    6 ++-
 drivers/net/wireless/libertas/rx.c      |    5 +--
 drivers/net/wireless/rt2x00/rt2800usb.c |    2 +-
 drivers/ssb/pci.c                       |    9 ++++--
 drivers/ssb/sprom.c                     |    1 +
 include/linux/netfilter/x_tables.h      |    2 +-
 include/linux/skbuff.h                  |    2 +-
 include/net/sock.h                      |   15 +---------
 net/caif/cfserl.c                       |    6 ++-
 net/core/skbuff.c                       |   42 ++++++++++++++++++++++-=
---
 net/ipv4/netfilter/ip_tables.c          |    2 +-
 net/ipv4/tcp_input.c                    |    4 +-
 net/ipv4/udp.c                          |    4 +-
 net/ipv6/netfilter/ip6_tables.c         |    2 +-
 net/ipv6/route.c                        |    2 +-
 net/mac80211/chan.c                     |    2 +-
 net/netfilter/x_tables.c                |   17 ++---------
 net/phonet/pep.c                        |    6 ++--
 net/rds/ib_cm.c                         |    1 +
 net/rds/iw_cm.c                         |    1 +
 29 files changed, 157 insertions(+), 90 deletions(-)
