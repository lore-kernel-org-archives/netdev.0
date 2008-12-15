From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 15 Dec 2008 01:27:17 -0800 (PST)
Message-ID: <20081215.012717.70229556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbYLOJ1Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 04:27:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Neil Horman fixes a race in netpoll resulting in corruption
   and crashes.

2) Packet scheduler comment fix from Jesper Brouer.

3) Thanks to reports, patches, and testing by Hermann Lauer
   the sungem driver PCS phy support is in at least some
   state of working.

4) IPV6 raw socket usage can spam the logs with multicast
   warnings, patch from Jan Sembera.

5) Another TCP Vegas fix from Doug Leith.

6) Mutex double-release fix in e1000e from Jeff Kirsher.

7) Fix another potential NULL deref in netlabel code, from
   Paul Moore.

8) Fix stray TX queue references after device is brought down
   in phonet layer, fix from R=E9mi Denis-Courmont.

9) rwlock initializer fix in netfilter from Steven Rostedt.

10) HP_SIMETH network driver doesn't depend upon NET, fix from
    Alexander Beregalov.

Please pull, thanks a lot!

The following changes since commit c49b9f295e513753e6d9bb4444ba502f1aa5=
9b29:
  Balazs Scheidler (1):
        tproxy: fixe a possible read from an invalid location in the so=
cket match

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Beregalov (1):
      IA64: HP_SIMETH needs to depend upon NET

David S. Miller (1):
      sungem: Make PCS PHY support partially work again.

Doug Leith (1):
      tcp: tcp_vegas cong avoid fix

Hermann Lauer (1):
      sungem: improve ethtool output with internal pcs and serdes

Jan Sembera (1):
      ipv6: silence log messages for locally generated multicast

Jeff Kirsher (1):
      e1000e: fix double release of mutex

Jesper Dangaard Brouer (1):
      SCHED: netem: Correct documentation comment in code.

Neil Horman (1):
      netpoll: fix race on poll_list resulting in garbage entry

Paul Moore (1):
      netlabel: Compiler warning and NULL pointer dereference fix

R=E9mi Denis-Courmont (1):
      Phonet: keep TX queue disabled when the device is off

Steven Rostedt (1):
      netfilter: update rwlock initialization for nat_table

 arch/ia64/hp/sim/Kconfig          |    1 +
 drivers/net/e1000e/ich8lan.c      |    9 ++-
 drivers/net/sungem.c              |  144 ++++++++++++++++++++++-------=
-------
 include/linux/netdevice.h         |    7 ++
 net/core/netpoll.c                |    2 +
 net/ipv4/netfilter/nf_nat_rule.c  |    2 +-
 net/ipv4/tcp_vegas.c              |   80 +++------------------
 net/ipv6/ndisc.c                  |    7 ++-
 net/netlabel/netlabel_unlabeled.c |   38 +++++-----
 net/phonet/pep-gprs.c             |   27 ++++++--
 net/sched/sch_netem.c             |    3 -
 11 files changed, 164 insertions(+), 156 deletions(-)
