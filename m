From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 19 May 2009 16:20:36 -0700 (PDT)
Message-ID: <20090519.162036.76263878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751361AbZESXUi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 19:20:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Back from the cruise, and somehow no better at shuffleboard than
before, here are the networking bug fixes that have accumulated.

Note that I did a merge because I pushed out the pulling in of
the bluetooth and wireless trees and only afterwards did I notice
that you had already pulled them in.  So it comes out as a wash.

As for the rest:

1) mlx4_en driver forgets to delete NAPI contexts, resulting in
   crashes.  Fix from Yevgeny Patrilin.

2) wimax/i2400m crash fixes from Inaky Perez-Gonzalez

3) Meth driver does not use IRQ disabling locks consistently, causing
   potential deadlocks.  Fix from Ralf Baechle.

4) Two non-STP bridge regression fixes from Stephen Hemminger.

5) Potential netpoll NULL deref got added by netdev_ops infrastructure
   changes, fix from Pavel Emelyanov.

6) Neterion driver programs FIFO registers improperly, fix from Roel Kl=
uin.

7) Two new device IDs fro be2net driver.

8) skb_seq_read doesn't handle all offset/length situations properly
   wrt. page frags, and this is most noticably seen as causing iSCSI
   login data corruption with certain devices.  Fix from Thomas Chenaul=
t.

9) TCP regression got added when we removed a MSG_PEEK test from tcp_re=
cvmsg()
   in order to adhere to rcvlowat like BSD does.  An assertion warning =
log
   message triggers when it shouldn't.  Fixed by Ilpo J=E4rvinen.

10) Fix mv643xx_eth on 32-bit PPC.  That platform no longer handles
    transparently NULL device args to the DMA interfaces.  Fix from
    Gabriel Paubert.

11) If a DHCP response is delayed, we process it using the wrong
    state if we send a request again meanwhile.  Fix from Chris Friesen=
=2E

12) Make INET_LRO behavior match it's help text.  From Frans Pop.

Please pull, thanks a lot!

The following changes since commit 279e677faa775ad16e75c32e1bf4a37f8158=
bc61:
  Linus Torvalds (1):
        Merge branch 'fixes-for-linus' of git://git.monstr.eu/linux-2.6=
-microblaze

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: add two new pci device ids to pci device table

Chris Friesen (1):
      ipconfig: handle case of delayed DHCP server

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../holtmann/blueto=
oth-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/
      Merge branch 'linux-2.6.30.y' of git://git.kernel.org/.../inaky/w=
imax

Eric Dumazet (2):
      sch_teql: should not dereference skb after ndo_start_xmit()
      pkt_sched: gen_estimator: use 64 bit intermediate counters for bp=
s

=46rans Pop (1):
      ipv4: make default for INET_LRO consistent with help text

Gabriel Paubert (1):
      mv643xx_eth: fix PPC DMA breakage

Ilpo J=E4rvinen (1):
      tcp: fix MSG_PEEK race check

Inaky Perez-Gonzalez (1):
      wimax/i2400m: fix device crash: fix optimization in _roq_queue_up=
date_ws

Pavel Emelyanov (1):
      netpoll: don't dereference NULL dev from np

Ralf Baechle (1):
      NET: Meth: Fix unsafe mix of irq and non-irq spinlocks.

Stephen Hemminger (3):
      bridge: relay bridge multicast pkgs if !STP
      bridge: fix initial packet flood if !STP
      bonding: fix link down handling in 802.3ad mode

Thomas Chenault (1):
      net: fix skb_seq_read returning wrong offset/length for page frag=
 data

Wang Tinggong (1):
      Doc: fixed descriptions on /proc/sys/net/core/* and /proc/sys/net=
/unix/*

Yevgeny Petrilin (1):
      mlx4_en: Fix not deleted napi structures

roel kluin (1):
      Neterion: *FIFO1_DMA_ERR set twice, should 2nd be *FIFO2_DMA_ERR?

 Documentation/networking/ip-sysctl.txt |   15 +++++++++--
 drivers/net/benet/be.h                 |   14 +++++++++++
 drivers/net/benet/be_main.c            |   10 ++++----
 drivers/net/bonding/bond_3ad.c         |   11 ++++++--
 drivers/net/meth.c                     |   27 +++++++++++----------
 drivers/net/mlx4/en_cq.c               |    4 ++-
 drivers/net/mv643xx_eth.c              |   41 +++++++++++++++++-------=
-------
 drivers/net/vxge/vxge-traffic.c        |    2 +-
 drivers/net/wimax/i2400m/rx.c          |    5 +--
 net/bridge/br_input.c                  |    5 ++++
 net/bridge/br_stp.c                    |    3 ++
 net/core/gen_estimator.c               |   13 +++++----
 net/core/netpoll.c                     |    8 ++++-
 net/core/skbuff.c                      |    2 +-
 net/ipv4/Kconfig                       |    2 +-
 net/ipv4/ipconfig.c                    |   12 +++++++++
 net/ipv4/tcp.c                         |    5 +++-
 net/sched/sch_teql.c                   |    5 ++-
 18 files changed, 123 insertions(+), 61 deletions(-)
