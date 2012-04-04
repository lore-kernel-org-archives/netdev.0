From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 0/6] arch/tile: provide tilegx networking support
Date: Wed, 4 Apr 2012 16:39:58 -0400
Message-ID: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change set provides support for the on-chip networking hardware
on the TILE-Gx chip.  The actual network driver is layered on top of
the mPIPE hardware support, which is layered on top of the GXIO IORPC
facility (and its DMA layer).  The change set breaks this down into
a series of patches, each progressively adding another component of
functionality.  There are also a couple of simple changes to add
support for MMIO memory mappings for readb/writeb, and for installing
MMIO PTEs, which are necessary for this change.

 arch/tile/Kconfig                         |    2 +
 arch/tile/Makefile                        |    1 +
 arch/tile/gxio/Kconfig                    |   25 +
 arch/tile/gxio/Makefile                   |    7 +
 arch/tile/gxio/dma_queue.c                |  236 ++++
 arch/tile/gxio/iorpc_globals.c            |  102 ++
 arch/tile/gxio/iorpc_mpipe.c              |  571 ++++++++
 arch/tile/gxio/iorpc_mpipe_info.c         |   95 ++
 arch/tile/gxio/kiorpc.c                   |   60 +
 arch/tile/gxio/mpipe.c                    |  631 +++++++++
 arch/tile/include/arch/mpipe.h            |  321 +++++
 arch/tile/include/arch/mpipe_constants.h  |   43 +
 arch/tile/include/arch/mpipe_def.h        |   39 +
 arch/tile/include/arch/mpipe_shm.h        |  421 ++++++
 arch/tile/include/arch/mpipe_shm_def.h    |   23 +
 arch/tile/include/asm/io.h                |  110 ++-
 arch/tile/include/gxio/common.h           |   40 +
 arch/tile/include/gxio/dma_queue.h        |   59 +
 arch/tile/include/gxio/iorpc_globals.h    |   38 +
 arch/tile/include/gxio/iorpc_mpipe.h      |  124 ++
 arch/tile/include/gxio/iorpc_mpipe_info.h |   46 +
 arch/tile/include/gxio/kiorpc.h           |   29 +
 arch/tile/include/gxio/mpipe.h            | 1986 ++++++++++++++++++++++++++++
 arch/tile/include/hv/drv_mpipe_intf.h     |  602 +++++++++
 arch/tile/include/hv/iorpc.h              |  716 ++++++++++
 arch/tile/mm/pgtable.c                    |   16 +-
 drivers/net/ethernet/tile/Kconfig         |    1 +
 drivers/net/ethernet/tile/Makefile        |    4 +-
 drivers/net/ethernet/tile/tilegx.c        | 2045 +++++++++++++++++++++++++++++
 29 files changed, 8359 insertions(+), 34 deletions(-)
