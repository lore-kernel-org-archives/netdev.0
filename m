From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 07 Jul 2011 04:32:21 -0700 (PDT)
Message-ID: <20110707.043221.1202835041176262898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab1GGLc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 07:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) iwl_tx_queue_reset() doesn't clear out the right number of slots,
   fix from Emmanuel Grumbach.

2) DMA buffer leak in iwlagn, fix from Johannes Berg.

3) iwlwifi command buffers need to be DMA mapped as "bidirectional" as
   the chip can write back to them sometimes, fix from Johannes Berg.

4) Fix OOPS in mac80211 on MIC failure, from Arik Nemtsov.

5) Fix lost power up during resume in ath9k, from Rajkumar Manoharan.

6) Memory leak in ath5k, fix from Bob Copeland.

7) 6pack/mkiss need to use BH locking, fix from Arnd Bergmann.

8) Get rid of artificial ipv6 routing table size limits, this is
   hitting real people now.

9) Don't send ICMP errors on local socket created MTU events.  Fix
   from Steffen Klassert.

10) Fix mailbox execution crash in qlge, from Jitendra Kalsaria.

11) Fix mixup between "spin_lock_irqsave()" flags and flags
    passed to request_irq in bna driver, fix from Shyam Iyer.

12) vlan_features not set properly in 8139too, from Shan Wei.

13) Fix DMA unmap length in natsemi, from FUJITA Tomonori.

14) Use more POSIX'ly correct when wrong address family is used
    during ipv4 bind().  From Marcus Meissner.

15) Fix MAC address setting in greth driver, from Kristoffer Glembo.

16) Regression fix, have to always flood broadcasts on bridge.  Fix
    from Herbert Xu.

17) Global memory limits of TCP/UDP/SCTP are miscalculated when lots
    of hugepages are reserved.  Fix from Eric Dumazet.

18) SCTP_SENDER_DRY_EVENT are not always sent when they should be, fix
    from Wei Yongjun.

Please pull, thanks a lot!

The following changes since commit 4dd1b49c6d215dc41ce50c80b4868388b93f31a3:

  Merge branch 'gpio/merge' of git://git.secretlab.ca/git/linux-2.6 (2011-07-06 18:36:53 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Arik Nemtsov (1):
      mac80211: fix rx->key NULL dereference during mic failure

Arnd Bergmann (1):
      6pack,mkiss: fix lock inconsistency

David S. Miller (3):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless-2.6
      ipv6: Don't change dst->flags using assignments.
      ipv6: Don't put artificial limit on routing table size.

Emmanuel Grumbach (1):
      iwlagn: Fix a bug introduced by the HUGE command removal

Eric Dumazet (1):
      net: refine {udp|tcp|sctp}_mem limits

Eugene A. Shatokhin (1):
      ath5k: fix memory leak when fewer than N_PD_CURVES are in use

Evgeni Golov (1):
      iwlagn: fix *_UCODE_API_MAX output in the firmware field

FUJITA Tomonori (1):
      natsemi: silence dma-debug warnings

Herbert Xu (1):
      bridge: Always flood broadcast packets

Jitendra Kalsaria (3):
      qlge:Fix crash caused by mailbox execution on wedged chip.
      qlge: Fix printk priority so chip fatal errors are always reported.
      qlge:Version change to v1.00.00.29

Johannes Berg (3):
      iwlagn: fix change_interface for P2P types
      iwlagn: fix cmd queue unmap
      iwlagn: map command buffers BIDI

John W. Linville (3):
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      iwlagn: use PCI_DMA_* for pci_* operations
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Kristoffer Glembo (1):
      greth: greth_set_mac_add would corrupt the MAC address.

Marcus Meissner (1):
      net: bind() fix error return on wrong address family

Rajkumar Manoharan (1):
      ath9k: Fix suspend/resume when no interface is UP

Shan Wei (2):
      net: 8139too: Initial necessary vlan_features to support vlan
      net: vlan: enable soft features regardless of underlying device

Shreyas Bhatewara (2):
      vmxnet3: fix starving rx ring whenoc_skb kb fails
      vmxnet3: round down # of queues to power of two

Shyam Iyer (1):
      Fix call trace when interrupts are disabled while sleeping function kzalloc is called

Steffen Klassert (3):
      xfrm: Remove family arg from xfrm_bundle_ok
      ipv4: Don't use ufo handling on later transformed packets
      xfrm4: Don't call icmp_send on local error

Wei Yongjun (1):
      sctp: fix missing send up SCTP_SENDER_DRY_EVENT when subscribe it

Yoshihiro Shimoda (2):
      net: sh_eth: fix cannot work half-duplex mode
      net: sh_eth: fix the parameter for the ETHER of SH7757

 drivers/net/8139too.c                   |    1 +
 drivers/net/bna/bnad.c                  |    7 +-
 drivers/net/greth.c                     |    7 +-
 drivers/net/hamradio/6pack.c            |    4 +-
 drivers/net/hamradio/mkiss.c            |    4 +-
 drivers/net/natsemi.c                   |    3 +-
 drivers/net/qlge/qlge.h                 |    3 +-
 drivers/net/qlge/qlge_main.c            |   42 ++++++----
 drivers/net/sh_eth.c                    |    6 +-
 drivers/net/vmxnet3/vmxnet3_drv.c       |  138 ++++++++++++++++++++++---------
 drivers/net/vmxnet3/vmxnet3_int.h       |    5 +-
 drivers/net/wireless/ath/ath5k/eeprom.c |    8 +-
 drivers/net/wireless/ath/ath9k/pci.c    |    6 ++
 drivers/net/wireless/iwlwifi/iwl-1000.c |    5 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c |    7 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c |    5 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c |    9 +-
 drivers/net/wireless/iwlwifi/iwl-core.c |    3 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c   |   25 ++----
 include/net/cfg80211.h                  |    2 +-
 include/net/dst.h                       |    1 +
 net/8021q/vlan_dev.c                    |    5 +
 net/bridge/br_device.c                  |    4 +-
 net/bridge/br_input.c                   |    6 +-
 net/core/dst.c                          |    6 +-
 net/ipv4/af_inet.c                      |    4 +-
 net/ipv4/ip_output.c                    |    2 +-
 net/ipv4/tcp.c                          |   10 +--
 net/ipv4/udp.c                          |   10 +--
 net/ipv4/xfrm4_output.c                 |    7 ++-
 net/ipv6/af_inet6.c                     |    2 +-
 net/ipv6/route.c                        |   25 ++----
 net/mac80211/wpa.c                      |    8 ++-
 net/sctp/protocol.c                     |   11 +--
 net/sctp/socket.c                       |   23 +++++
 net/wireless/nl80211.c                  |    3 +-
 net/xfrm/xfrm_policy.c                  |    6 +-
 37 files changed, 257 insertions(+), 166 deletions(-)
