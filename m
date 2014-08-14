From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 14 Aug 2014 16:16:19 -0700 (PDT)
Message-ID: <20140814.161619.481143718108046707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm sending this out, in particular, to get the iwlwifi fix propagated:

1) Fix build due to missing include in i40e driver, from Lucas Tanure.

2) Memory leak in openvswitch port allocation, from Chirstoph Jaeger.

3) Check DMA mapping errors in myri10ge, from Stanislaw Gruszka.

4) Fix various deadlock scenerios in sunvnet driver, from Sowmini Varadhan.

5) Fix cxgb4i build failures with incompatible Kconfig settings of the
   driver vs. ipv6, from Anish Bhatt.

6) Fix generation of ACK packet timestamps in the presence of TSO which
   will be split up, from Willem de Bruijn.

7) Don't enable sched scan in iwlwifi driver, it causes firmware crashes
   in some revisions.  From Emmanuel Grumbach.

8) Revert a macvlan simplification that causes crashes.

9) Handle RTT calculations properly in the presence of repair'd SKBs,
   from Andrey Vagin.

10) SIT tunnel lookup uses wrong device index in compares, from
    Shmulik Ladkani.

11) Handle MTU reductions in TCP properly for ipv4 mapped ipv6 sockets,
    from Neal Cardwell.

12) Add missing annotations in rhashtable code, from Thomas Graf.

13) Fix false interpretation of two RTOs as being from the same TCP
    loss event in the FRTO code, from Neal Cardwell.

Please pull, thanks a lot!

The following changes since commit f0094b28f3038936c1985be64dbe83f0e950b671:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-08-13 18:27:40 -0600)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to a61ebdfdb13a051f707b408d464f63b991aa21e3:

  Merge tag 'master-2014-08-14' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2014-08-14 15:17:37 -0700)

----------------------------------------------------------------

Andreas Ruprecht (1):
      net: ethernet: ibm: ehea: Remove duplicate object from Makefile

Andrey Vagin (1):
      tcp: don't use timestamp from repaired skb-s to calculate RTT (v2)

Anish Bhatt (1):
      libcxgbi/cxgb4i : Fix ipv6 build failure caught with randconfig

Arend van Spriel (2):
      brcmfmac: fix curly brace mistake in brcmf_pcie_handle_mb_data()
      brcmfmac: fix memory leakage in msgbuf

Christoph Jaeger (1):
      openvswitch: Fix memory leak in ovs_vport_alloc() error path

David S. Miller (5):
      Merge branch 'xen-netback-debugfs'
      Merge branch 'xen-netback-synchronization'
      Merge git://git.kernel.org/.../jkirsher/net
      Revert "macvlan: simplify the structure port"
      Merge tag 'master-2014-08-14' of git://git.kernel.org/.../linville/wireless

Emmanuel Grumbach (1):
      iwlwifi: mvm: disable scheduled scan to prevent firmware crash

Govindarajulu Varadarajan (1):
      tg3: fix return value in tg3_get_stats64

Hannes Frederic Sowa (1):
      tcp: don't allow syn packets without timestamps to pass tcp_tw_recycle logic

Jean Sacren (2):
      e1000e: fix trivial kernel doc typos
      e1000e: delete excessive space character in debug message

Julia Lawall (1):
      i40e: use correct structure type name in sizeof

Libo Chen (1):
      drivers/net/irda/donauboe.c: convert to module_pci_driver

Lucas Tanure (1):
      i40e: Fix missing uapi/linux/dcbnl.h include in i40e_fcoe.c

Maks Naumov (1):
      irda: Fix rd_frame control field initialization in irlap_send_rd_frame()

Michal Simek (1):
      net: xilinx: Remove .owner field for driver

Neal Cardwell (2):
      tcp: fix tcp_release_cb() to dispatch via address family for mtu_reduced()
      tcp: fix ssthresh and undo for consecutive short FRTO episodes

Rickard Strandqvist (2):
      net: wireless: ipw2x00: ipw2200.c: Cleaning up missing null-terminate after strncpy call
      i40e: Cleaning up missing null-terminate in conjunction with strncpy

Ronald Wahl (1):
      carl9170: fix sending URBs with wrong type when using full-speed

Shmulik Ladkani (1):
      sit: Fix ipip6_tunnel_lookup device matching criteria

Sowmini Varadhan (3):
      sunvnet: Do not ask for an ACK for every dring transmit
      sunvnet: Do not spin in an infinite loop when vio_ldc_send() returns EAGAIN
      sunvnet: Schedule maybe_tx_wakeup() as a tasklet from ldc_rx path

Stanislaw Gruszka (1):
      myri10ge: check for DMA mapping errors

Thomas Graf (4):
      rhashtable: RCU annotations for next pointers
      rhashtable: unexport and make rht_obj() static
      rhashtable: fix annotations for rht_for_each_entry_rcu()
      netlink: Annotate RCU locking for seq_file walker

Tobias Klauser (1):
      net: xgene: Check negative return value of xgene_enet_get_ring_size()

Wei Liu (5):
      xen-netback: fix debugfs write length check
      xen-netback: fix debugfs entry creation
      xen-netback: move NAPI add/remove calls
      xen-netback: don't stop dealloc kthread too early
      xen-netback: remove loop waiting function

Wei Yongjun (1):
      i40e: fix sparse non static symbol warning

Willem de Bruijn (2):
      net-timestamp: fix missing ACK timestamp
      net-timestamp: fix missing tcp fragmentation cases

chas williams - CONTRACTOR (2):
      atm/svc: Fix blocking in wait loop
      lec: Fix bug introduced by b67bfe0d42cac56c512dd5da4b1b347a23f4b70a

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  7 +++--
 drivers/net/ethernet/broadcom/tg3.c               |  3 ++-
 drivers/net/ethernet/ibm/ehea/Makefile            |  2 +-
 drivers/net/ethernet/intel/e1000e/manage.c        |  4 +--
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c       |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 18 ++++++-------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c        |  6 ++---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  | 88 ++++++++++++++++++++++++++++++++++++++++---------------------
 drivers/net/ethernet/sun/sunvnet.c                | 38 +++++++++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet.h                |  4 +++
 drivers/net/ethernet/xilinx/ll_temac_main.c       |  1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |  1 -
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |  1 -
 drivers/net/irda/donauboe.c                       | 15 +----------
 drivers/net/macvlan.c                             | 12 +++++----
 drivers/net/wireless/ath/carl9170/carl9170.h      |  1 +
 drivers/net/wireless/ath/carl9170/usb.c           | 31 +++++++++++++++++++---
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c  |  4 +++
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c    |  3 ++-
 drivers/net/wireless/ipw2x00/ipw2200.c            |  1 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c       |  3 ++-
 drivers/net/xen-netback/common.h                  |  5 ++++
 drivers/net/xen-netback/interface.c               | 56 ++++++++++++++++-----------------------
 drivers/net/xen-netback/netback.c                 | 26 +++++++++++++-----
 drivers/net/xen-netback/xenbus.c                  | 17 +++++++-----
 drivers/scsi/cxgbi/cxgb3i/Kconfig                 |  2 +-
 drivers/scsi/cxgbi/cxgb4i/Kconfig                 |  2 +-
 include/linux/rhashtable.h                        | 17 +++++-------
 include/net/inet_connection_sock.h                |  1 +
 include/net/sock.h                                |  1 -
 include/net/tcp.h                                 |  7 +++--
 lib/rhashtable.c                                  | 10 ++-----
 net/atm/lec.c                                     |  5 +---
 net/atm/svc.c                                     | 60 +++++++++++++++++++++--------------------
 net/ipv4/tcp.c                                    | 14 +++++-----
 net/ipv4/tcp_input.c                              | 27 ++++++++++---------
 net/ipv4/tcp_ipv4.c                               |  5 ++--
 net/ipv4/tcp_metrics.c                            |  6 +++--
 net/ipv4/tcp_output.c                             | 24 +++++++++++++++--
 net/ipv6/sit.c                                    |  6 ++---
 net/ipv6/tcp_ipv6.c                               |  3 ++-
 net/irda/irlap_frame.c                            |  2 +-
 net/netlink/af_netlink.c                          |  2 ++
 net/openvswitch/vport.c                           |  4 ++-
 44 files changed, 332 insertions(+), 214 deletions(-)
