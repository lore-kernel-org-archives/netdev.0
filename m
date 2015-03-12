From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 0/8] powerpc/8xx: Getting rid of CONFIG_8xx
Date: Thu, 12 Mar 2015 16:24:20 +0100 (CET)
Message-ID: <20150312152420.11C821A2425@localhost.localdomain>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-mtd@lists.infradead.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	scottwood@freescale.com, Jeff Dike <jdike@addtoit.com>,
	Richard Weinberger <richard@nod.at>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	David Woodhouse <dwmw2@infradead.org>,
	Brian Norris <computersforpeace@gmail.com>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two config options exist to define powerpc MPC8xx:
* CONFIG_PPC_8xx
* CONFIG_8xx
In addition, CONFIG_PPC_8xx also defines CONFIG_CPM1 as
communication co-processor

arch/powerpc/platforms/Kconfig.cputype has contained the following
comment about CONFIG_8xx item for some years:
"# this is temp to handle compat with arch=ppc"

It looks like not many places still have that old CONFIG_8xx used,
so it is likely to be a good time to get rid of it completely ?

Patchset is composed of the following patches:
[1/8] powerpc: replace CONFIG_8xx by CONFIG_PPC_8xx
[2/8] um: replace CONFIG_8xx by CONFIG_PPC_8xx
[3/8] video: replace CONFIG_8xx by CONFIG_PPC_8xx
[4/8] net: freescale: replace CONFIG_8xx by CONFIG_PPC_8xx
[5/8] tty: cpm_uart: replace CONFIG_8xx by CONFIG_CPM1
[6/8] mtd: replace CONFIG_8xx by CONFIG_PPC_8xx
[7/8] isdn: replace CONFIG_8xx by CONFIG_PPC_8xx
[8/8] powerpc: get rid of CONFIG_8xx

All but the last one are independant and can be applied in any
order. Only the 8th one requires the first 7 patches to be applied.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

---
 arch/powerpc/Kconfig                             | 10 +++++-----
 arch/powerpc/Makefile                            |  2 +-
 arch/powerpc/boot/Makefile                       |  4 ++--
 arch/powerpc/boot/util.S                         |  6 +++---
 arch/powerpc/include/asm/cache.h                 |  2 +-
 arch/powerpc/include/asm/cputable.h              |  4 ++--
 arch/powerpc/include/asm/fs_pd.h                 |  2 +-
 arch/powerpc/include/asm/pgtable-ppc32.h         |  2 +-
 arch/powerpc/include/asm/ppc_asm.h               |  4 ++--
 arch/powerpc/include/asm/reg.h                   | 10 +++++-----
 arch/powerpc/include/asm/timex.h                 |  4 ++--
 arch/powerpc/kernel/Makefile                     |  2 +-
 arch/powerpc/kernel/cputable.c                   |  4 ++--
 arch/powerpc/kernel/irq.c                        |  2 +-
 arch/powerpc/kernel/kgdb.c                       |  4 ++--
 arch/powerpc/kernel/misc_32.S                    |  4 ++--
 arch/powerpc/kernel/traps.c                      |  6 +++---
 arch/powerpc/kernel/vdso32/gettimeofday.S        |  2 +-
 arch/powerpc/mm/fault.c                          |  4 ++--
 arch/powerpc/mm/init_32.c                        |  4 ++--
 arch/powerpc/mm/mem.c                            |  2 +-
 arch/powerpc/mm/mmu_decl.h                       | 12 ++++++------
 arch/powerpc/mm/tlb_nohash_low.S                 |  2 +-
 arch/powerpc/platforms/8xx/Kconfig               |  3 +--
 arch/powerpc/platforms/Kconfig.cputype           |  7 +------
 arch/powerpc/sysdev/Makefile                     |  2 +-
 arch/powerpc/sysdev/fsl_soc.c                    |  3 ++-
 arch/powerpc/sysdev/fsl_soc.h                    |  3 ++-
 arch/powerpc/xmon/xmon.c                         |  2 +-
 arch/um/sys-ppc/misc.S                           | 12 ++++++------
 drivers/isdn/hardware/mISDN/Kconfig              |  4 ++--
 drivers/mtd/maps/Kconfig                         |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c |  2 +-
 drivers/net/ethernet/freescale/fs_enet/mac-scc.c |  2 +-
 drivers/tty/serial/Kconfig                       |  2 +-
 drivers/tty/serial/cpm_uart/Makefile             |  2 +-
 drivers/tty/serial/cpm_uart/cpm_uart.h           |  2 +-
 drivers/video/console/Kconfig                    |  2 +-
 38 files changed, 72 insertions(+), 76 deletions(-)
