From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 08 Dec 2008 00:06:55 -0800 (PST)
Message-ID: <20081208.000655.211323914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbYLHIGz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 03:06:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the pending net fixes:

1) TPROXY code accesses invalid socket struct memory.  Fix from=09
   Balazs Scheidler.

2) listen() on ATM socket multiple times corrupts VCC table.
   Fix thanks to Chas Williams.

3) TCP vegas congestion control doesn't hit ssthresh properly in
   all cases, from Doug Leith.

4) Two CAN socket layer filtering API fixes from Oliver Hartkopp.

5) Really fix URG handling with TSO, from Ilpo J=E4rvinen.

6) netlabel OOPS'er fix from Paul Moore.

7) 32/64 bit field access bug in HYSDN isdn driver from Pascal Terjan.

8) A few small wireless driver bug fixes via John Linville.

9) netx-eth driver doesn't initialize the driver spinlock, resulting
   in warnings from lock checking, from Uwe Kleine-K=F6nig.

10) Missing list_del() in policy flushing leads to complete
    corruption of the policy tables.  Fix from Wei Yongjun.

11) b1isa_exit() in isdn drivers does not release CAPI controllers
    resulting in all kinds of problems.  From Wilfried Klaebe.

12) Fix from R=E9mi Denis-Courmont to keep phonet socket layer from
    dumping sockets outside of the current namespace.

13) Packet data read in enc28j60 driver doesn't use the correct buffer
    offset in the wraparound cases, resulting in data loss.  Fix from
    Baruch Siach based upon suggestions from Shachar Shemesh.

Please pull, thanks a lot!

The following changes since commit f6f7b52e2f6149d2ee365717afff315b0572=
0162:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../wim/linux-2.6-watchdog

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Balazs Scheidler (1):
      tproxy: fixe a possible read from an invalid location in the sock=
et match

Baruch Siach (1):
      enc28j60: Fix sporadic packet loss (corrected again)

Chas Williams (1):
      ATM: CVE-2008-5079: duplicate listen() on socket corrupts the vcc=
 table

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Doug Leith (1):
      tcp: tcp_vegas ssthresh bug fix

Ilpo J=E4rvinen (1):
      tcp: make urg+gso work for real this time

Michael Chan (1):
      bnx2: Add workaround to handle missed MSI.

Oliver Hartkopp (2):
      can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
      can: omit received RTR frames for single ID filter lists

Pascal Terjan (1):
      hysdn: fix writing outside the field on 64 bits

Paul Moore (1):
      netlabel: Fix a potential NULL pointer dereference

Shaddy Baddah (2):
      mac80211: use unaligned safe memcmp() in-place of compare_ether_a=
ddr()
      zd1211rw: use unaligned safe memcmp() in-place of compare_ether_a=
ddr()

Tomas Winkler (1):
      iwlwifi: clean key table in iwl_clear_stations_table function

Uwe Kleine-K=F6nig (1):
      netx-eth: initialize per device spinlock

Wei Yongjun (1):
      xfrm: Fix kernel panic when flush and dump SPD entries

Wilfried Klaebe (1):
      b1isa: fix b1isa_exit() to really remove registered capi controll=
ers

Zhu Yi (1):
      ipw2200: fix netif_*_queue() removal regression

remi.denis-courmont@nokia (1):
      Phonet: do not dump addresses from other namespaces

 drivers/isdn/hardware/avm/b1isa.c       |    6 +--
 drivers/isdn/hysdn/hysdn_net.c          |    4 +-
 drivers/net/bnx2.c                      |   35 ++++++++++++++-
 drivers/net/bnx2.h                      |    6 +++
 drivers/net/enc28j60.c                  |   16 ++++++-
 drivers/net/netx-eth.c                  |    2 +
 drivers/net/wireless/ipw2200.c          |    4 ++
 drivers/net/wireless/iwlwifi/iwl-core.c |    3 +
 drivers/net/wireless/iwlwifi/iwl-sta.c  |   24 +++++++++-
 drivers/net/wireless/zd1211rw/zd_mac.c  |    2 +-
 include/linux/can/core.h                |    2 +-
 net/atm/svc.c                           |    6 ++-
 net/can/af_can.c                        |   68 +++++++++++++++++++++++=
-------
 net/can/bcm.c                           |    7 ++-
 net/ipv4/tcp_output.c                   |   22 +++++-----
 net/ipv4/tcp_vegas.c                    |    2 +
 net/mac80211/sta_info.c                 |    2 +-
 net/netfilter/xt_socket.c               |    2 +-
 net/netlabel/netlabel_unlabeled.c       |   10 +++--
 net/phonet/pn_netlink.c                 |    3 +
 net/xfrm/xfrm_policy.c                  |    1 +
 21 files changed, 173 insertions(+), 54 deletions(-)
