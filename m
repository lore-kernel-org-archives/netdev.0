From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2 0/6] arch/tile: networking support for tilegx
Date: Wed, 4 Apr 2012 16:39:58 -0400
Message-ID: <201204291856.q3TIusXq007168@farm-0027.internal.tilera.com>
References: <201204062059.q36KxjEO011317@farm-0027.internal.tilera.com> <201204101042.39877.arnd@arndb.de> <4F8763E1.1020605@tilera.com> <201204131034.03544.arnd@arndb.de> <4F9C6A0A.5090109@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Arnd Bergmann <arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F9C6A0A.5090109@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series addresses the feedback from the community for the
first patch series.  Changes include:

- Clean up network driver to not keep two arrays of net_device pointers
- Use explicit tile_io_addr type and conversion functions, not __pa/__va
- Avoid tile-specific __insn_mf() in favor of wmb()
- Clean up checksumming in tilegx.c to use new csum_long() routine
- Use inline assembly for readb/writeb etc to avoid splitting accesses
- Remove fences after mmio writes since they aren't necessary
- Fixed Kconfig options to be appropriately hidden
- Export symbols with EXPORT_SYMBOL_GPL, nestled up against the functions
- Make auto-generated code much terser and more readable
- Avoid typedef'ing structures, and remove "_t" suffix from struct names
- Convert remaining C99 comments to C89
- Fixed driver multiline comment style to match davem's preferred style

 arch/tile/Kconfig                         |    2 +
 arch/tile/Makefile                        |    2 +
 arch/tile/gxio/Kconfig                    |   17 +
 arch/tile/gxio/Makefile                   |    7 +
 arch/tile/gxio/dma_queue.c                |  230 ++++
 arch/tile/gxio/iorpc_globals.c            |   89 ++
 arch/tile/gxio/iorpc_mpipe.c              |  463 +++++++
 arch/tile/gxio/iorpc_mpipe_info.c         |   85 ++
 arch/tile/gxio/kiorpc.c                   |   61 +
 arch/tile/gxio/mpipe.c                    |  500 ++++++++
 arch/tile/include/arch/mpipe.h            |  359 ++++++
 arch/tile/include/arch/mpipe_constants.h  |   42 +
 arch/tile/include/arch/mpipe_def.h        |   39 +
 arch/tile/include/arch/mpipe_shm.h        |  509 ++++++++
 arch/tile/include/arch/mpipe_shm_def.h    |   23 +
 arch/tile/include/asm/checksum.h          |   18 +
 arch/tile/include/asm/io.h                |  144 ++-
 arch/tile/include/gxio/common.h           |   38 +
 arch/tile/include/gxio/dma_queue.h        |   59 +
 arch/tile/include/gxio/iorpc_globals.h    |   38 +
 arch/tile/include/gxio/iorpc_mpipe.h      |  124 ++
 arch/tile/include/gxio/iorpc_mpipe_info.h |   46 +
 arch/tile/include/gxio/kiorpc.h           |   29 +
 arch/tile/include/gxio/mpipe.h            | 1653 ++++++++++++++++++++++++
 arch/tile/include/hv/drv_mpipe_intf.h     |  602 +++++++++
 arch/tile/include/hv/iorpc.h              |  714 +++++++++++
 arch/tile/lib/checksum.c                  |   15 +-
 drivers/net/ethernet/tile/Kconfig         |    1 +
 drivers/net/ethernet/tile/Makefile        |    4 +-
 drivers/net/ethernet/tile/tilegx.c        | 1952 +++++++++++++++++++++++++++++
 30 files changed, 7821 insertions(+), 44 deletions(-)
