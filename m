From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 01 Jun 2015 17:17:22 -0700 (PDT)
Message-ID: <20150601.171722.1966882885860474515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbbFBARX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 20:17:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Various VTI tunnel (mark handling, PMTU) bug fixes from Alexander Duyck
   and Steffen Klassert.

2) Revert ethtool PHY query change, it wasn't correct.  The PHY address
   selected by the driver running the PHY to MAC connection decides
   what PHY address GET ethtool operations return information from.

3) Fix handling of sequence number bits for encryption IV generation
   in ESP driver, from Herbert Xu.

4) UDP can return -EAGAIN when we hit a bad checksum on receive, even
   when there are other packets in the receive queue which is wrong.
   Just respect the error returned from the generic socket recv
   datagram helper.  From Eric Dumazet.

5) Fix BNA driver firmware loading on big-endian systems, from Ivan
   Vecera.

6) Fix regression in that we were inheriting the congestion control
   of the listening socket for new connections, the intended behavior
   always was to use the default in this case.  From Neal Cardwell.

7) Fix NULL deref in brcmfmac driver, from Arend van Spriel.

8) OTP parsing fix in iwlwifi from Liad Kaufman.

Please pull, thanks!

The following changes since commit de182468d1bb726198abaab315820542425270b7:

  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6 (2015-05-27 14:09:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net 

for you to fetch changes up to e453581dd518f60b45a8d2b9cf344e2a87d5267e:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-06-01 16:56:43 -0700)

----------------------------------------------------------------
Alexander Duyck (3):
      ip_vti/ip6_vti: Do not touch skb->mark on xmit
      xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input
      ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call

Arend van Spriel (1):
      brcmfmac: avoid null pointer access when brcmf_msgbuf_get_pktid() fails

Bernhard Thaler (1):
      Revert "netfilter: ensure number of counters is >0 in do_replace()"

Daniel Pieczko (1):
      sfc: free multiple Rx buffers when required

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Merge tag 'mac80211-for-davem-2015-05-28' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'bna-fixes'
      Revert "net: core: 'ethtool' issue with querying phy settings"
      Merge tag 'wireless-drivers-for-davem-2015-06-01' of git://git.kernel.org/.../kvalo/wireless-drivers
      Merge git://git.kernel.org/.../pablo/nf

Eric Dumazet (2):
      bridge: fix br_multicast_query_expired() bug
      udp: fix behavior of wrong checksums

Florian Fainelli (1):
      net: dsa: Properly propagate errors from dsa_switch_setup_one

Herbert Xu (3):
      esp4: Use high-order sequence number bits for IV generation
      esp6: Use high-order sequence number bits for IV generation
      xfrm: Always zero high-order sequence number bits

Ian Campbell (2):
      xen: netback: fix printf format string warning
      xen: netback: read hotplug script once at start of day.

Ilan Peer (1):
      iwlwifi: pcie: fix tracking of cmd_in_flight

Ivan Vecera (3):
      bna: fix firmware loading on big-endian machines
      bna: remove unreasonable iocpf timer start
      bna: fix soft lock-up during firmware initialization failure

Jonathan Corbet (1):
      mac80211: Fix mac80211.h docbook comments

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-05-28' of https://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Li RongQing (1):
      xfrm: fix a race in xfrm_state_lookup_byspi

Liad Kaufman (1):
      iwlwifi: nvm: fix otp parsing in 8000 hw family

Neal Cardwell (1):
      tcp: fix child sockets to use system default congestion control if not set

Roger Luethi (1):
      via-rhine: Resigning as maintainer

Steffen Klassert (1):
      vti6: Add pmtu handling to vti6_xmit.

Yuval Mintz (1):
      bnx2x: Move statistics implementation into semaphores

 MAINTAINERS                                       |  3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  9 ++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 20 +++++++----
 drivers/net/ethernet/brocade/bna/bfa_ioc.c        |  4 +--
 drivers/net/ethernet/brocade/bna/bnad.c           |  4 ---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c      |  7 ++++
 drivers/net/ethernet/sfc/rx.c                     | 42 ++++++++++++++---------
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c  | 12 +++----
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c      |  2 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h      |  6 ++--
 drivers/net/wireless/iwlwifi/pcie/trans.c         |  4 +--
 drivers/net/wireless/iwlwifi/pcie/tx.c            | 23 +++++--------
 drivers/net/xen-netback/netback.c                 |  2 +-
 drivers/net/xen-netback/xenbus.c                  | 33 ++++++++++--------
 include/net/inet_connection_sock.h                |  3 +-
 include/net/mac80211.h                            |  7 ++--
 net/bridge/br_multicast.c                         |  2 +-
 net/bridge/netfilter/ebtables.c                   |  4 ---
 net/core/ethtool.c                                | 10 +-----
 net/dsa/dsa.c                                     |  4 +--
 net/ipv4/esp4.c                                   |  3 +-
 net/ipv4/ip_vti.c                                 | 14 +++++---
 net/ipv4/tcp_cong.c                               |  5 ++-
 net/ipv4/tcp_minisocks.c                          |  5 ++-
 net/ipv4/udp.c                                    |  6 ++--
 net/ipv6/esp6.c                                   |  3 +-
 net/ipv6/ip6_vti.c                                | 27 +++++++++++++--
 net/ipv6/udp.c                                    |  6 ++--
 net/xfrm/xfrm_input.c                             | 17 ++++++++-
 net/xfrm/xfrm_replay.c                            |  2 ++
 net/xfrm/xfrm_state.c                             |  2 +-
 32 files changed, 174 insertions(+), 119 deletions(-)
