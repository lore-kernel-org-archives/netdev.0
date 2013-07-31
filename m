From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v2] tile: handle 64-bit statistics in tilepro network
 driver
Date: Tue, 30 Jul 2013 20:34:52 -0400
Message-ID: <51F85BAC.70101@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com> <40362053a9f02d56a4f0c07a9982d96203723ec8.1374609948.git.cmetcalf@tilera.com> <201307251642.r6PGgHx2002404@farm-0012.internal.tilera.com> <20130730.161634.1378046909890599017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730.161634.1378046909890599017.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/30/2013 7:16 PM, David Miller wrote:
> From: Chris Metcalf <cmetcalf@tilera.com>
> Date: Thu, 25 Jul 2013 12:41:15 -0400
>
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> Applied, thanks.
>
> Your PTP patch for the Tile driver doesn't even come close to
> applying properly to net-next, please respin it and report if
> you want me to apply it.
>
> Thanks.

It might be easiest to pull the whole series from:

  git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git tile-net-next

Chris Metcalf (13):
      tile: handle 64-bit statistics in tilepro network driver
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
 drivers/net/ethernet/tile/tilegx.c        | 1097 +++++++++++++++++++----------
 drivers/net/ethernet/tile/tilepro.c       |  206 ++----
 10 files changed, 1100 insertions(+), 505 deletions(-)

Aside from the tilepro 64-bit stats change, and the PTP change, the other
changes didn't receive any substantive feedback.  (Eric Dumazet pointed
out that explicit NETIF_F_GRO was unnecessary, so I removed it.)

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
