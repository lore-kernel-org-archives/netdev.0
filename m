From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 29 Oct 2010 12:59:20 -0700 (PDT)
Message-ID: <20101029.125920.189692530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756043Ab0J2T64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 15:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This has the verify_iovec() INT_MAX limiter change as well as:

1) kdump fix in netxen from Rajesh Borundia

2) 8390 oops in probe regression fix from Pavel Emelyanov

3) ipv4 routing table memory leak on namespace stop, also from Pavel
   Emelyanov.

4) cxgb3 probe OOPS fix from Nishanth Aravamudan

5) Limit kernel stack usage of root in pktgen, from Nelson Elhage,
   although this needs a few more tweaks I think.

6) Fix panic in cxgb3 tx desc freeing, from Krishna Kumar.

7) DCCP updates from Gerrit Renker

8) pch_gbe build fix, due to missing dependency

9) Signedness fix in netfilte xt_socket code.

10) Atheros driver fixes from Felix Fietkau, Jones Desougi, Luis
    R. Rodriguez, Mohammed Shafi Shajakhan, and Rajkumar Manoharan

Please pull, thanks a lot!

The following changes since commit 1e431a9d6478940c0b5fcfa1c17a336fc0683409:

  Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jwessel/linux-2.6-kgdb (2010-10-29 11:49:38 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Carolyn Wyborny (2):
      e1000e: reset PHY after errors detected
      e1000e: Add check for reset flags before displaying reset message

David S. Miller (4):
      pch_gbe: Select MII.
      net: Limit socket I/O iovec total length to INT_MAX.
      netfilter: xt_socket: Make tproto signed in socket_mt6_v1().
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Dmitry Artamonow (1):
      USB: gadget: fix ethernet gadget crash in gether_setup

Emil Tantilov (2):
      ixgb: call pci_disable_device in ixgb_remove
      igbvf: fix panic on load

Felix Fietkau (1):
      ath9k: fix tx aggregation flush on AR9003

Geert Uytterhoeven (1):
      net: atarilance - flags should be unsigned long

Gerrit Renker (4):
      dccp: Return-value convention of hc_tx_send_packet()
      dccp: Extend CCID packet dequeueing interface
      dccp: Refine the wait-for-ccid mechanism
      dccp ccid-2: Stop polling

Jesper Juhl (1):
      mac80211: fix failure to check kmalloc return value in key_key_read

Jesse Gross (1):
      igb: Fix unused variable warning.

John Fastabend (1):
      ixgbe: DCB, fix TX hang occurring in stress condition with PFC

Jones Desougi (1):
      ath5k: Fix double free on hw attach error path

Jouni Malinen (1):
      mac80211: Fix scan_ies_len to include DS Params

Krishna Kumar (1):
      cxgb3: Fix panic in free_tx_desc()

Larry Finger (1):
      b43: Fix warning at drivers/mmc/core/core.c:237 in mmc_wait_for_cmd

Luis R. Rodriguez (4):
      ath9k: add locking for stopping RX
      ath9k: add locking for starting the PCU on RX
      ath9k: rename rxflushlock to pcu_lock
      ath9k: lock reset and PCU start/stopping

Mohammed Shafi Shajakhan (1):
      ath9k: Fix incorrect access of rate flags in RC

Nelson Elhage (1):
      pktgen: Limit how much data we copy onto the stack.

Nishanth Aravamudan (1):
      cxgb3: fix crash due to manipulating queues before registration

Paul Fox (1):
      libertas: Fix sd8686 firmware reload

Pavel Emelyanov (2):
      8390: Don't oops on starting dev queue
      fib: Fix fib zone and its hash leak on namespace stop

Rajesh Borundia (1):
      netxen: fix kdump

Rajkumar Manoharan (1):
      ath9k_htc: Set proper firmware offset for Netgear WNDA3200

avisconti (1):
      stmmac: enable/disable rx/tx in the core with a single write.

 drivers/net/Kconfig                      |    1 +
 drivers/net/atarilance.c                 |    2 +-
 drivers/net/cxgb3/cxgb3_main.c           |    2 +-
 drivers/net/cxgb3/sge.c                  |    4 +-
 drivers/net/e1000e/82571.c               |   38 ++++++
 drivers/net/e1000e/e1000.h               |    3 +
 drivers/net/e1000e/netdev.c              |   29 ++++-
 drivers/net/igb/igb_main.c               |    1 -
 drivers/net/igbvf/netdev.c               |    8 +-
 drivers/net/ixgb/ixgb_main.c             |    1 +
 drivers/net/ixgbe/ixgbe_dcb.c            |   39 +++++-
 drivers/net/ixgbe/ixgbe_dcb.h            |    5 +-
 drivers/net/ixgbe/ixgbe_dcb_82599.c      |    5 +
 drivers/net/ixgbe/ixgbe_dcb_82599.h      |    3 +
 drivers/net/ixgbe/ixgbe_main.c           |   12 ++-
 drivers/net/lib8390.c                    |    1 -
 drivers/net/netxen/netxen_nic_ctx.c      |   15 --
 drivers/net/netxen/netxen_nic_main.c     |    7 +
 drivers/net/stmmac/stmmac_main.c         |   40 ++-----
 drivers/net/wireless/ath/ath5k/attach.c  |   17 +--
 drivers/net/wireless/ath/ath9k/ath9k.h   |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c |   10 +-
 drivers/net/wireless/ath/ath9k/main.c    |   31 ++++-
 drivers/net/wireless/ath/ath9k/rc.c      |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c    |   15 +-
 drivers/net/wireless/ath/ath9k/xmit.c    |   18 ++--
 drivers/net/wireless/b43/sdio.c          |    2 +
 drivers/net/wireless/libertas/if_sdio.c  |   32 ++++-
 drivers/usb/gadget/u_ether.c             |    2 +-
 include/linux/dccp.h                     |    4 +-
 include/linux/socket.h                   |    2 +-
 include/net/ip_fib.h                     |    2 +
 net/compat.c                             |   10 +-
 net/core/iovec.c                         |   20 ++--
 net/core/pktgen.c                        |    7 +-
 net/dccp/ccid.h                          |   34 +++++-
 net/dccp/ccids/ccid2.c                   |   23 ++-
 net/dccp/ccids/ccid2.h                   |    5 +
 net/dccp/ccids/ccid3.c                   |   12 +-
 net/dccp/dccp.h                          |    5 +-
 net/dccp/output.c                        |  209 ++++++++++++++++++------------
 net/dccp/proto.c                         |   21 +++-
 net/dccp/timer.c                         |   27 ++--
 net/ipv4/fib_frontend.c                  |    2 +-
 net/ipv4/fib_hash.c                      |   18 +++
 net/ipv4/fib_trie.c                      |    5 +
 net/mac80211/debugfs_key.c               |    6 +-
 net/mac80211/main.c                      |    5 +-
 net/netfilter/xt_socket.c                |    7 +-
 49 files changed, 525 insertions(+), 246 deletions(-)
