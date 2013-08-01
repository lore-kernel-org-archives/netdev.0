From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3 00/13] update tile network drivers
Date: Thu, 1 Aug 2013 15:25:19 -0400
Message-ID: <cover.1375385119.git.cmetcalf@tilera.com>
References: <20130801.113100.2059303096028571906.davem@davemloft.net>
    <799eca39dc7f85ba12e1d8c5b072f8b6740fda1c.1375283106.git.cmetcalf@tilera.com>
    <20130731.122534.774117327230299927.davem@redhat.com>
    <201308011545.r71Fjbco017295@farm-0002.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130801.113100.2059303096028571906.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is v3 of the patch series to update the Tilera network drivers.

>From the v1 00/13 cover letter: "This patch series contains changes made
to the Tilera on-chip network drivers for both the 64-bit tilegx and
32-bit tilepro architectures.  The changes involve a number of bug fixes,
support for the multiple mPIPEs on the new Gx72 chip, support for jumbo
frames, TSO for IPv6, GRO, PTP support, and statistics improvements."

David has already applied the v2 patch for what was patch 01/13 in the
first series ("handle 64-bit statistics in tilepro network driver")
so it is not included in this v3 series.

Changes from the v1 series include:

- Nearly complete rewrite of PTP changes based on feedback from
  Richard Cochran
- Removal of NETIF_F_GRO as unnecessary (from Eric Dumazet)
- A few minor whitespace and code style changes

Changes from the v2 series:

- use of dev->hw_features instead of just dev->features

Chris Metcalf (13):
  tile: set hw_features and vlan_features in setup
  tile: support rx_dropped/rx_errors in tilepro net driver
  tile: avoid bug in tilepro net driver built with old hypervisor
  tile: remove dead is_dup_ack() function from tilepro net driver
  tile: support jumbo frames in the tilegx network driver
  tile: update dev->stats directly in tilegx network driver
  tile: fix panic bug in napi support for tilegx network driver
  tile: enable GRO in the tilegx network driver
  tile: support multiple mPIPE shims in tilegx network driver
  tile: support TSO for IPv6 in tilegx network driver
  tile: make "tile_net.custom" a proper bool module parameter
  tile: remove deprecated NETIF_F_LLTX flag from tile drivers
  tile: support PTP using the tilegx mPIPE (IEEE 1588)

 arch/tile/gxio/iorpc_mpipe.c              |   66 ++
 arch/tile/gxio/iorpc_mpipe_info.c         |   18 +
 arch/tile/gxio/mpipe.c                    |   43 +-
 arch/tile/include/gxio/iorpc_mpipe.h      |   14 +-
 arch/tile/include/gxio/iorpc_mpipe_info.h |    4 +
 arch/tile/include/gxio/mpipe.h            |  143 +++-
 arch/tile/include/hv/drv_mpipe_intf.h     |    3 +
 drivers/net/ethernet/tile/Kconfig         |   11 +
 drivers/net/ethernet/tile/tilegx.c        | 1112 +++++++++++++++++++----------
 drivers/net/ethernet/tile/tilepro.c       |  164 +----
 10 files changed, 1069 insertions(+), 509 deletions(-)

-- 
1.8.3.1
