From: David Miller <davem@davemloft.net>
Subject: Fw: [GIT] Networking
Date: Wed, 11 May 2016 15:29:39 -0400 (EDT)
Message-ID: <20160511.152939.1370671483651845525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_May_11_15_29_39_2016_349)--"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----Next_Part(Wed_May_11_15_29_39_2016_349)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Sorry, forgot to CC: the lists on the initial send.

----Next_Part(Wed_May_11_15_29_39_2016_349)--
Content-Type: Message/Rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Date: Wed, 11 May 2016 15:27:28 -0400 (EDT)
Message-Id: <20160511.152728.1913900691450128778.davem@davemloft.net>
To: torvalds@linux-foundation.org
CC: akpm@linux-foundation.org
Subject: [GIT] Networking
From: David Miller <davem@davemloft.net>
X-Mailer: Mew version 6.6 on Emacs 24.5 / Mule 6.0 (HANACHIRUSATO)
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hopefully the last round of fixes this release, fingers crossed :)

1) Initialize static nf_conntrack_locks_all_lock properly, from
   Florian Westphal.

2) Need to cancel pending work when destroying IDLETIMER entries, from
   Liping Zhang.

3) Fix TX param usage when sending TSO over iwlwifi devices, from
   Emmanuel Grumbach.

4) NFACCT quota params not validated properly, from Phil Turnbull.

5) Resolve more glibc vs. kernel header conflicts, from Mikko Tapeli.

6) Missing IRQ free in ravb_close(), from Geert Uytterhoeven.

7) Fix infoleak in x25, from Kangjie Lu.

8) Similarly in thunderx driver, from Heinrich Schuchardt.

9) tc_ife.h uapi header not exported properly, from Jamal Hadi Salim.

10) Don't reenable PHY interreupts if device is in polling mode, from
    Shaohui Xie.

11) Packet scheduler actions late binding was not being handled properly
    at all, from Jamal Hadi Salim.

12) Fix binding of conntrack entries to helpers in openvswitch, from
    Joe Stringer.

Please pull, thanks a lot!

The following changes since commit b507146bb6b9ac0c0197100ba3e299825a21fed3:

  Merge branch 'linus' of git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6 (2016-05-09 12:24:19 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to e271c7b4420ddbb9fae82a2b31a5ab3edafcf4fe:

  gre: do not keep the GRE header around in collect medata mode (2016-05-11 15:16:32 -0400)

----------------------------------------------------------------
David S. Miller (4):
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'wireless-drivers-for-davem-2016-05-09' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge branch 'nps_enet-fixes'
      Merge branch 'net-sched-fixes'

Elad Kanfi (2):
      net: nps_enet: Tx handler synchronization
      net: nps_enet: bug fix - handle lost tx interrupts

Emmanuel Grumbach (1):
      iwlwifi: mvm: don't override the rate with the AMSDU len

Eric Dumazet (1):
      tcp: refresh skb timestamp at retransmit time

Florian Westphal (1):
      netfilter: conntrack: init all_locks to avoid debug warning

Geert Uytterhoeven (1):
      ravb: Add missing free_irq() call to ravb_close()

Jamal Hadi Salim (7):
      export tc ife uapi header
      net sched: vlan action fix late binding
      net sched: ipt action fix late binding
      net sched: mirred action fix late binding
      net sched: simple action fix late binding
      net sched: skbedit action fix late binding
      net sched: ife action fix late binding

Jiri Benc (1):
      gre: do not keep the GRE header around in collect medata mode

Joe Stringer (1):
      openvswitch: Fix cached ct with helper.

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-05-04' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Kangjie Lu (1):
      net: fix a kernel infoleak in x25 module

Liping Zhang (1):
      netfilter: IDLETIMER: fix race condition when destroy the target

Mikko Rapeli (1):
      uapi glibc compat: fix compile errors when glibc net/if.h included before linux/if.h

Phil Turnbull (1):
      netfilter: nfnetlink_acct: validate NFACCT_QUOTA parameter

Shaohui Xie (1):
      net: phylib: fix interrupts re-enablement in phy_start

xypron.glpk@gmx.de (1):
      net: thunderx: avoid exposing kernel stack

 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  4 ++++
 drivers/net/ethernet/ezchip/nps_enet.c             | 30 ++++++++++++++++++++++++------
 drivers/net/ethernet/ezchip/nps_enet.h             |  2 --
 drivers/net/ethernet/renesas/ravb_main.c           |  2 ++
 drivers/net/phy/phy.c                              |  8 +++++---
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        | 83 ++++++++++++++++++++++++++++++++++++++++++++++++-----------------------------------
 include/uapi/linux/if.h                            | 28 ++++++++++++++++++++++++++++
 include/uapi/linux/libc-compat.h                   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/tc_act/Kbuild                   |  1 +
 net/ipv4/ip_gre.c                                  |  7 ++++++-
 net/ipv4/tcp_output.c                              |  6 ++++--
 net/netfilter/nf_conntrack_core.c                  |  2 +-
 net/netfilter/nfnetlink_acct.c                     |  2 ++
 net/netfilter/xt_IDLETIMER.c                       |  1 +
 net/openvswitch/conntrack.c                        | 13 +++++++++++++
 net/sched/act_ife.c                                | 14 ++++++++++----
 net/sched/act_ipt.c                                | 19 ++++++++++++-------
 net/sched/act_mirred.c                             | 19 +++++++++++++------
 net/sched/act_simple.c                             | 18 ++++++++++++------
 net/sched/act_skbedit.c                            | 18 +++++++++++-------
 net/sched/act_vlan.c                               | 22 ++++++++++++++++------
 net/x25/x25_facilities.c                           |  1 +
 22 files changed, 258 insertions(+), 86 deletions(-)

----Next_Part(Wed_May_11_15_29_39_2016_349)----
