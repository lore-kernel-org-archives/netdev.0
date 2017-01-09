From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 08 Jan 2017 22:38:47 -0500 (EST)
Message-ID: <20170108.223847.1035900535306187665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933629AbdAIDiu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 22:38:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix dumping of nft_quota entries, from Pablo Neira Ayuso.

2) Fix out of bounds access in nf_tables discovered by KASAN,
   from Florian Westphal.

3) Fix IRQ enabling in dp83867 driver, from Grygorii Strashko.

4) Fix unicast filtering in be2net driver, from Ivan Vecera.

5) tg3_get_stats64() can race with driver close and ethtool
   reconfigurations, fix from Michael Chan.

6) Fix error handling when pass limit is reached in bpf code
   gen on x86.  From Daniel Borkmann.

7) Don't clobber switch ops and use proper MDIO nested reads
   and writes in bcm_sf2 driver, from Florian Fainelli.

Please pull, thanks a lot!

The following changes since commit e02003b515e8d95f40f20f213622bb82510873d2:

  Merge tag 'xfs-for-linus-4.10-rc3' of git://git.kernel.org/pub/scm/fs/xfs/xfs-linux (2017-01-04 18:33:35 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to 03430fa10b99e95e3a15eb7c00978fb1652f3b24:

  Merge branch 'bcm_sf2-fixes' (2017-01-08 22:01:22 -0500)

----------------------------------------------------------------
Artur Molchanov (1):
      bridge: netfilter: Fix dropping packets that moving through bridge interface

Daniel Borkmann (1):
      bpf: change back to orig prog on too many passes

David Forster (1):
      vti6: fix device register to report IFLA_INFO_KIND

David S. Miller (3):
      Merge git://git.kernel.org/.../pablo/nf
      Merge tag 'mac80211-for-davem-2017-01-06' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'bcm_sf2-fixes'

Florian Fainelli (2):
      net: dsa: bcm_sf2: Do not clobber b53_switch_ops
      net: dsa: bcm_sf2: Utilize nested MDIO read/write

Florian Westphal (1):
      netfilter: nf_tables: fix oob access

Grygorii Strashko (1):
      net: phy: dp83867: fix irq generation

Ivan Vecera (2):
      be2net: fix accesses to unicast list
      be2net: fix unicast list filling

Johannes Berg (1):
      nl80211: fix sched scan netlink socket owner destruction

Kweh, Hock Leong (1):
      net: stmmac: fix maxmtu assignment to be within valid range

Lendacky, Thomas (1):
      amd-xgbe: Fix IRQ processing when running in single IRQ mode

Michael Chan (1):
      tg3: Fix race condition in tg3_get_stats64().

Pablo Neira Ayuso (3):
      netfilter: nft_quota: reset quota after dump
      netfilter: nft_queue: use raw_smp_processor_id()
      netfilter: nft_payload: mangle ckecksum if NFT_PAYLOAD_L4CSUM_PSEUDOHDR is set

Paul Moore (1):
      netlabel: add CALIPSO to the list of built-in protocols

Sergei Shtylyov (2):
      sh_eth: fix EESIPR values for SH77{34|63}
      sh_eth: R8A7740 supports packet shecksumming

Xin Long (1):
      netfilter: ipt_CLUSTERIP: check duplicate config when initializing

Zhu Yanjun (1):
      r8169: fix the typo in the comment

 arch/x86/net/bpf_jit_comp.c                       |  2 ++
 drivers/net/dsa/bcm_sf2.c                         | 11 +++++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c          |  2 +-
 drivers/net/ethernet/broadcom/tg3.c               |  3 +++
 drivers/net/ethernet/emulex/benet/be_main.c       | 12 ++++--------
 drivers/net/ethernet/realtek/r8169.c              |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c             |  5 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 +++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c  |  6 ++++++
 drivers/net/phy/dp83867.c                         | 10 ++++++++++
 net/bridge/br_netfilter_hooks.c                   |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                | 34 +++++++++++++++++++++++-----------
 net/ipv6/ip6_vti.c                                |  2 +-
 net/netfilter/nf_tables_api.c                     |  2 +-
 net/netfilter/nft_payload.c                       | 27 +++++++++++++++++++--------
 net/netfilter/nft_queue.c                         |  2 +-
 net/netfilter/nft_quota.c                         | 26 ++++++++++++++------------
 net/netlabel/netlabel_kapi.c                      |  5 +----
 net/wireless/nl80211.c                            | 16 +++++++---------
 19 files changed, 116 insertions(+), 63 deletions(-)
