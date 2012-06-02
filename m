From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 02 Jun 2012 17:31:59 -0400 (EDT)
Message-ID: <20120602.173159.675662966124767026.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965826Ab2FBVcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 17:32:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Make syn floods consume significantly less resources by

   a) Not pre-COW'ing routing metrics for SYN/ACKs
   b) Mirroring the device queue mapping of the SYN for the SYN/ACK
      reply.

   Both from Eric Dumazet.

2) Fix calculation errors in Byte Queue Limiting, from Hiroaki SHIMODA.

3) Validate the length requested when building a paged SKB for a
   socket, so we don't overrun the page vector accidently.  From Jason
   Wang.

4) When netlabel is disabled, we abort all IP option processing when
   we see a CIPSO option.  This isn't the right thing to do, we should
   simply skip over it and continue processing the remaining options
   (if any).  Fix from Paul Moore.

5) SRIOV fixes for the mellanox driver from Jack orgenstein and Marcel
   Apfelbaum.

6) 8139cp enables the receiver before the ring address is properly
   programmed, which potentially lets the device crap over random
   memory.  Fix from Jason Wang.

7) e1000/e1000e fixes for i217 RST handling, and an improper buffer
   address reference in jumbo RX frame processing from Bruce Allan
   and Sebastian Andrzej Siewior, respectively.

Please pull, thanks a lot!

The following changes since commit 76f901eb4659779ecacd0e4eba49f55442daef53:

  Merge tag 'for-v3.5' of git://git.infradead.org/battery-2.6 (2012-05-31 12:10:15 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 9ca3cc6f3026946ba655e863ca2096339e667639:

  fec_mpc52xx: fix timestamp filtering (2012-06-02 17:09:08 -0400)

----------------------------------------------------------------
Bruce Allan (1):
      e1000e: fix Rapid Start Technology support for i217

Devendra Naga (1):
      r8169: call netif_napi_del at errpaths and at driver unload

Eric Dumazet (2):
      tcp: do not create inetpeer on SYNACK message
      tcp: reflect SYN queue_mapping into SYNACK packets

Hiroaki SHIMODA (3):
      bql: Fix POSDIFF() to integer overflow aware.
      bql: Avoid unneeded limit decrement.
      bql: Avoid possible inconsistent calculation.

Jack Morgenstein (5):
      net/mlx4_core: Fix the slave_id out-of-range test in mlx4_eq_int
      net/mlx4_en: Fix improper use of "port" parameter in mlx4_en_event
      net/mlx4_core: Fixes for VF / Guest startup flow
      net/mlx4_core: Check port out-of-range before using in mlx4_slave_cap
      net/mlx4_core: Fix obscure mlx4_cmd_box parameter in QUERY_DEV_CAP

Jason Wang (3):
      net: sock: validate data_len before allocating skb in sock_alloc_send_pskb()
      8139cp: set ring address before enabling receiver
      8139cp/8139too: terminate the eeprom access with the right opmode

Marcel Apfelbaum (1):
      net/mlx4_core: Fix number of EQs used in ICM initialisation

Ondrej Zary (1):
      mcs7830: Implement link state detection

Paul Moore (1):
      cipso: handle CIPSO options correctly when NetLabel is disabled

Sebastian Andrzej Siewior (1):
      e1000: look into the page instead of skb->data for e1000_tbi_adjust_stats()

Stephan Gatzka (1):
      fec_mpc52xx: fix timestamp filtering

 drivers/net/ethernet/freescale/fec_mpc52xx.c  |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |    2 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.c   |   18 +++++++++---------
 drivers/net/ethernet/mellanox/mlx4/cmd.c      |    4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c  |   12 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/eq.c       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c       |   51 +++++++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/main.c     |   40 +++++++++++++--------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h     |   10 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/profile.c  |    9 ++++++---
 drivers/net/ethernet/realtek/8139cp.c         |   24 ++++++++++++------------
 drivers/net/ethernet/realtek/8139too.c        |    2 +-
 drivers/net/ethernet/realtek/r8169.c          |    3 +++
 drivers/net/usb/mcs7830.c                     |   25 +++++++++++++++++++++++--
 include/linux/mlx4/device.h                   |    6 ++++++
 include/net/cipso_ipv4.h                      |   29 +++++++++++++++++++++++++++-
 lib/dynamic_queue_limits.c                    |   18 +++++++++++-------
 net/core/sock.c                               |    7 +++++--
 net/ipv4/inet_connection_sock.c               |    3 ++-
 net/ipv4/tcp_ipv4.c                           |    9 ++++++---
 net/ipv6/tcp_ipv6.c                           |    9 ++++++---
 21 files changed, 201 insertions(+), 84 deletions(-)
