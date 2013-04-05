From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 05 Apr 2013 16:41:29 -0400 (EDT)
Message-ID: <20130405.164129.913167048310203214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix erroneous sock_orphan() leading to crashes and double kfree_skb() in
   NFC protocol.  From Thierry Escande and Samuel Ortiz.

2) Fix use after free in remain-on-channel mac80211 code, from Johannes
   Berg.

3) nf_reset() needs to reset the NF tracing cookie, otherwise we can leak
   it from one namespace into another.   Fix from Gao Feng and Patrick
   McHardy.

4) Fix overflow in channel scanning array of mwifiex driver, from Stone
   Piao.

5) Fix loss of link after suspend/shutdown in r8169, from Hayes Wang.

6) Synchronization of unicast address lists to the undelying device doesn't
   work because whether to sync is maintained as a boolean rather than a
   true count.  Fix from Vlad Yasevich.

7) Fix corruption of TSO packets in atl1e by limiting the segmented packet
   length.  From Hannes Frederic Sowa.

8) Revert bogus AF_UNIX credential passing change and fix the coalescing
   issue properly, from Eric W. Biederman.

9) Changes of ipv4 address lifetime settings needs to generate a notification,
   from Jiri Pirko.

Please pull, thanks a lot!

The following changes since commit da241efcd9c3da2af6ba20055c7e158ec725005c:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-04-02 18:58:01 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 124dff01afbdbff251f0385beca84ba1b9adda68:

  netfilter: don't reset nf_trace in nf_reset() (2013-04-05 15:38:10 -0400)

----------------------------------------------------------------
David S. Miller (2):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless into wireless
      Merge branch 'master' of git://1984.lsi.us.es/nf

Eric W. Biederman (2):
      Revert "af_unix: dont send SCM_CREDENTIAL when dest socket is NULL"
      af_unix: If we don't care about credentials coallesce all messages

Gao feng (1):
      netfilter: reset nf_trace in nf_reset

Hannes Frederic Sowa (1):
      atl1e: limit gso segment size to prevent generation of wrong ip length fields

Jakub Kicinski (1):
      ixgbe: fix registration order of driver and DCA nofitication

Jiri Pirko (1):
      net: ipv4: notify when address lifetime changes

Johannes Berg (3):
      mac80211: fix remain-on-channel cancel crash
      mac80211: fix idle handling sequence
      iwlwifi: dvm: fix the passive-no-RX workaround

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes
      Merge tag 'nfc-fixes-3.9-2' of git://git.kernel.org/.../sameo/nfc-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Matthias Schiffer (1):
      netfilter: ip6t_NPT: Fix translation for non-multiple of 32 prefix lengths

Pablo Neira Ayuso (1):
      netfilter: nfnetlink_acct: return -EINVAL if object name is empty

Patrick McHardy (1):
      netfilter: don't reset nf_trace in nf_reset()

Samuel Ortiz (3):
      NFC: llcp: Detach socket from process context only when releasing the socket
      NFC: llcp: Keep the connected socket parent pointer alive
      NFC: microread: Fix build failure due to a new MEI bus API

Stone Piao (1):
      mwifiex: limit channel number not to overflow memory

Thierry Escande (1):
      NFC: llcp: Remove possible double call to kfree_skb

Veaceslav Falico (1):
      bonding: remove sysfs before removing devices

Vlad Yasevich (1):
      net: count hw_addr syncs so that unsync works properly.

Wei Yongjun (2):
      netfilter: nfnetlink_queue: fix error return code in nfnetlink_queue_init()
      netfilter: nf_conntrack: fix error return code

hayeswang (1):
      r8169: fix auto speed down issue

 drivers/net/bonding/bond_main.c                 |  2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e.h      |  2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 11 +++++++++--
 drivers/net/ethernet/realtek/r8169.c            | 28 +++++++++++++++++++++++++---
 drivers/net/wireless/iwlwifi/dvm/rxon.c         | 18 ++++++++----------
 drivers/net/wireless/iwlwifi/dvm/tx.c           |  2 +-
 drivers/net/wireless/mwifiex/cfg80211.c         |  3 ++-
 drivers/nfc/microread/mei.c                     | 38 +++++++++++++++++---------------------
 include/linux/netdevice.h                       |  2 +-
 include/linux/skbuff.h                          |  7 +++++++
 net/core/dev.c                                  |  1 +
 net/core/dev_addr_lists.c                       |  6 +++---
 net/ipv4/devinet.c                              |  6 ++++--
 net/ipv6/netfilter/ip6t_NPT.c                   |  2 +-
 net/mac80211/cfg.c                              |  6 ++++--
 net/mac80211/chan.c                             | 17 ++++++++++++++---
 net/mac80211/ieee80211_i.h                      |  4 +++-
 net/mac80211/iface.c                            |  2 +-
 net/mac80211/offchannel.c                       | 23 +++++++++++++++++------
 net/netfilter/nf_conntrack_standalone.c         |  1 +
 net/netfilter/nfnetlink_acct.c                  |  2 ++
 net/netfilter/nfnetlink_queue_core.c            |  4 +++-
 net/nfc/llcp/llcp.c                             |  8 --------
 net/nfc/llcp/sock.c                             |  6 +++---
 net/unix/af_unix.c                              |  6 +++---
 26 files changed, 133 insertions(+), 75 deletions(-)
