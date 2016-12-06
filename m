From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 06 Dec 2016 12:04:04 -0500 (EST)
Message-ID: <20161206.120404.141364032650056590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbcLFREG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:04:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) When dcbnl_cee_fill() fails to be able to push a new netlink attribute, it
   return 0 instead of an error code.  From Pan Bian.

2) Two suffix handling fixes to FIB trie code, from Alexander Duyck.

3) bnxt_hwrm_stat_ctx_alloc() goes through all the trouble of setting
   and maintaining a return code 'rc' but fails to actually return it.
   Also from Pan Bian.

4) ping socket ICMP handler needs to validate ICMP header length, from
   Kees Cook.

5) caif_sktinit_module() has this interesting logic:

	int err = sock_register(...);
	if (!err)
		return err;
	return 0;

   Just return sock_register()'s return value directly which is the only
   possible correct thing to do.

6) Two bnx2x driver fixes from Yuval Mintz, return a reasonable estimate
   from get_ringparam() ethtool op when interface is down and avoid trying
   to use UDP port based tunneling on 577xx chips.

7) Fix ep93xx_eth crash on module unload from Florian Fainelli.

8) Missing uapi exports, from Stephen Hemminger.

9) Don't schedule work from sk_destruct(), because the socket will be
   freed upon return from that function.  From Herbert Xu.

10) Buggy drivers, of which we know there is at least one, can send a huge
    packet into the TCP stack but forget to set the gso_size in the SKB,
    which causes all kinds of problems.

    Correct this when it happens, and emit a one-time warning with
    the device name included so that it can be diagnosed more easily.

    From Marcelo Ricardo Leitner.

11) virtio-net does DMA off the stack causes hiccups with VMAP_STACK,
    fix from Andy Lutomirski.

12) Fix fec driver compilation with CONFIG_M5272, from Nikita
    Yushchenko.

13) mlx5 fixes from Kamal Heib, Saeed Mahameed, and Mohamad Haj Yahia.
    (erroneously flushing queues on error, module parameter validation,
    etc.)

Please pull, thanks a lot!

The following changes since commit 8dc0f265d39a3933f4c1f846c7c694f12a2ab88a:

  Merge tag 'fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc (2016-12-02 13:34:37 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 32f16e142d7acabad68ef27c123d0caf1548aac3:

  Merge branch 'mlx5-fixes' (2016-12-06 11:44:45 -0500)

----------------------------------------------------------------
Alexander Duyck (2):
      ipv4: Drop leaf from suffix pull/push functions
      ipv4: Drop suffix update from resize code

Andy Lutomirski (1):
      virtio-net: Fix DMA-from-the-stack in virtnet_set_mac_address()

David S. Miller (4):
      Merge tag 'batadv-net-for-davem-20161202' of git://git.open-mesh.org/linux-merge
      Merge branch 'fib-suffix-length-fixes'
      Merge branch 'bnx2x-fixes'
      Merge branch 'mlx5-fixes'

Florian Fainelli (1):
      net: ep93xx_eth: Do not crash unloading module

Herbert Xu (1):
      netlink: Do not schedule work from sk_destruct

Jonas Gorski (1):
      uapi glibc compat: fix outer guard of net device flags enum

Kamal Heib (3):
      net/mlx5: Verify module parameters
      net/mlx5: Remove duplicate pci dev name print
      net/mlx5: Fix query ISSI flow

Kees Cook (1):
      net: ping: check minimum size on ICMP header length

Marcelo Ricardo Leitner (1):
      tcp: warn on bogus MSS and try to amend it

Mintz, Yuval (2):
      bnx2x: Correct ringparam estimate when DOWN
      bnx2x: Prevent tunnel config for 577xx

Mohamad Haj Yahia (1):
      net/mlx5e: Change the SQ/RQ operational state to positive logic

Nikita Yushchenko (1):
      net: fec: fix compile with CONFIG_M5272

Niklas Cassel (1):
      net: stmmac: clear reset value of snps, wr_osr_lmt/snps, rd_osr_lmt before writing

Pan Bian (11):
      net: dcb: set error code on failures
      netdev: broadcom: propagate error code
      net: bridge: set error code on failure
      net: usb: set error code when usb_alloc_urb fails
      atm: lanai: set error code when ioremap fails
      net: caif: remove ineffective check
      net: irda: set error code on failures
      atm: fix improper return value
      net: ethernet: qlogic: set error code on failure
      net: bnx2x: fix improper return value
      isdn: hisax: set error code on failure

Saeed Mahameed (2):
      net/mlx5e: Don't notify HW when filling the edge of ICO SQ
      net/mlx5e: Don't flush SQ on error

Suraj Deshmukh (1):
      net: af_mpls.c add space before open parenthesis

Sven Eckelmann (1):
      batman-adv: Check for alloc errors when preparing TT local data

Venkat Duvvuru (1):
      be2net: Add DEVSEC privilege to SET_HSW_CONFIG command.

stephen hemminger (2):
      uapi: export tc_skbmod.h
      uapi: export nf_log.h

 drivers/atm/eni.c                                     |  2 +-
 drivers/atm/lanai.c                                   |  1 +
 drivers/isdn/hisax/hfc4s8s_l1.c                       |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c   |  8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  5 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c             |  2 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c              |  4 ++++
 drivers/net/ethernet/emulex/benet/be_cmds.c           |  3 ++-
 drivers/net/ethernet/freescale/fec_main.c             | 13 ++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c         |  5 -----
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     | 15 +++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c       |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c     |  4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c        | 42 +++++++++++++++++++++++++-----------------
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h   | 15 ++++++++++-----
 drivers/net/ethernet/qlogic/qed/qed_ll2.c             |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c   |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c      |  2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  6 ++++--
 drivers/net/irda/irda-usb.c                           |  1 +
 drivers/net/usb/lan78xx.c                             |  1 +
 drivers/net/virtio_net.c                              | 19 ++++++++++++++-----
 include/uapi/linux/if.h                               |  4 ++--
 include/uapi/linux/netfilter/Kbuild                   |  1 +
 include/uapi/linux/tc_act/Kbuild                      |  1 +
 net/batman-adv/translation-table.c                    |  4 ++--
 net/bridge/br_sysfs_br.c                              |  1 +
 net/caif/caif_socket.c                                |  5 +----
 net/dcb/dcbnl.c                                       |  1 +
 net/ipv4/fib_trie.c                                   | 68 +++++++++++++++++++++++++++++++++++---------------------------------
 net/ipv4/ping.c                                       |  4 ++++
 net/ipv4/tcp_input.c                                  | 22 +++++++++++++++++++++-
 net/mpls/af_mpls.c                                    |  2 +-
 net/netlink/af_netlink.c                              | 32 +++++++++++++++-----------------
 36 files changed, 194 insertions(+), 117 deletions(-)
