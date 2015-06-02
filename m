From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v5] QE: Move QE from arch/powerpc to drivers/soc
Date: Mon, 1 Jun 2015 21:53:24 -0500
Message-ID: <1433213604.3415.8.camel@freescale.com>
References: <1433212650-29579-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Zhao Qiang <B45475@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:34157
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753893AbbFBCxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jun 2015 22:53:36 -0400
In-Reply-To: <1433212650-29579-1-git-send-email-B45475@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-02 at 10:37 +0800, Zhao Qiang wrote:
> ls1 has qe and ls1 has arm cpu.
> move qe from arch/powerpc to drivers/soc/fsl
> to adapt to powerpc and arm
> 
> Signed-off-by: Zhao Qiang <B45475@freescale.com>
> ---
> Changes for v2:
>       - move code to driver/soc
> Changes for v3:
>       - change drivers/soc/qe to drivers/soc/fsl-qe
> Changes for v4:
>       - move drivers/soc/fsl-qe to drivers/soc/fsl/qe
>       - move head files for qe from include/linux/fsl to include/soc/fsl
>       - move qe_ic.c to drivers/irqchip/
> Changes for v5:
>       - update MAINTAINERS
> 
>  MAINTAINERS                                        |  5 +++--
>  arch/powerpc/platforms/83xx/km83xx.c               |  4 ++--
>  arch/powerpc/platforms/83xx/misc.c                 |  2 +-
>  arch/powerpc/platforms/83xx/mpc832x_mds.c          |  4 ++--
>  arch/powerpc/platforms/83xx/mpc832x_rdb.c          |  4 ++--
>  arch/powerpc/platforms/83xx/mpc836x_mds.c          |  4 ++--
>  arch/powerpc/platforms/83xx/mpc836x_rdk.c          |  4 ++--
>  arch/powerpc/platforms/85xx/common.c               |  2 +-
>  arch/powerpc/platforms/85xx/corenet_generic.c      |  2 +-
>  arch/powerpc/platforms/85xx/mpc85xx_mds.c          |  4 ++--
>  arch/powerpc/platforms/85xx/mpc85xx_rdb.c          |  4 ++--
>  arch/powerpc/platforms/85xx/twr_p102x.c            |  4 ++--
>  arch/powerpc/platforms/Kconfig                     | 19 ------------
> ------
>  arch/powerpc/sysdev/qe_lib/Kconfig                 | 23 ++++++------
> ----------
>  arch/powerpc/sysdev/qe_lib/Makefile                | 10 +++-------
>  arch/powerpc/sysdev/qe_lib/gpio.c                  |  2 +-
>  arch/powerpc/sysdev/qe_lib/qe_io.c                 |  2 +-
>  arch/powerpc/sysdev/qe_lib/usb.c                   |  4 ++--
>  drivers/irqchip/Makefile                           |  1 +
>  .../sysdev/qe_lib => drivers/irqchip}/qe_ic.c      |  2 +-
>  .../sysdev/qe_lib => drivers/irqchip}/qe_ic.h      |  2 +-
>  drivers/net/ethernet/freescale/fsl_pq_mdio.c       |  2 +-
>  drivers/net/ethernet/freescale/ucc_geth.c          |  8 ++++----
>  drivers/net/ethernet/freescale/ucc_geth.h          |  8 ++++----
>  drivers/soc/Kconfig                                |  2 ++
>  drivers/soc/Makefile                               |  1 +
>  drivers/soc/fsl/Makefile                           |  5 +++++
>  .../sysdev/qe_lib => drivers/soc/fsl/qe}/Kconfig   | 16 +++++++++---
> ---
>  drivers/soc/fsl/qe/Makefile                        |  8 ++++++++
>  .../sysdev/qe_lib => drivers/soc/fsl/qe}/qe.c      |  4 ++--
>  .../sysdev/qe_lib => drivers/soc/fsl/qe}/ucc.c     |  6 +++---
>  .../qe_lib => drivers/soc/fsl/qe}/ucc_fast.c       |  8 ++++----
>  .../qe_lib => drivers/soc/fsl/qe}/ucc_slow.c       |  8 ++++----
>  drivers/spi/spi-fsl-cpm.c                          |  2 +-
>  drivers/tty/serial/ucc_uart.c                      |  2 +-
>  drivers/usb/gadget/fsl_qe_udc.c                    |  2 +-
>  drivers/usb/host/fhci-hcd.c                        |  2 +-
>  drivers/usb/host/fhci-hub.c                        |  2 +-
>  drivers/usb/host/fhci-sched.c                      |  2 +-
>  drivers/usb/host/fhci.h                            |  4 ++--
>  .../include/asm => include/linux/fsl}/qe_ic.h      |  0
>  .../include/asm => include/soc/fsl}/immap_qe.h     |  0
>  {arch/powerpc/include/asm => include/soc/fsl}/qe.h |  2 +-
>  .../powerpc/include/asm => include/soc/fsl}/ucc.h  |  4 ++--
>  .../include/asm => include/soc/fsl}/ucc_fast.h     |  6 +++---
>  .../include/asm => include/soc/fsl}/ucc_slow.h     |  6 +++---
>  46 files changed, 103 insertions(+), 115 deletions(-)
>  rename {arch/powerpc/sysdev/qe_lib => drivers/irqchip}/qe_ic.c (99%)
>  rename {arch/powerpc/sysdev/qe_lib => drivers/irqchip}/qe_ic.h (98%)
>  create mode 100644 drivers/soc/fsl/Makefile
>  copy {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/Kconfig 
> (50%)
>  create mode 100644 drivers/soc/fsl/qe/Makefile
>  rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/qe.c (99%)
>  rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/ucc.c 
> (98%)
>  rename {arch/powerpc/sysdev/qe_lib => 
> drivers/soc/fsl/qe}/ucc_fast.c (99%)
>  rename {arch/powerpc/sysdev/qe_lib => 
> drivers/soc/fsl/qe}/ucc_slow.c (98%)
>  rename {arch/powerpc/include/asm => include/linux/fsl}/qe_ic.h 
> (100%)
>  rename {arch/powerpc/include/asm => include/soc/fsl}/immap_qe.h 
> (100%)
>  rename {arch/powerpc/include/asm => include/soc/fsl}/qe.h (99%)
>  rename {arch/powerpc/include/asm => include/soc/fsl}/ucc.h (96%)
>  rename {arch/powerpc/include/asm => include/soc/fsl}/ucc_fast.h 
> (98%)
>  rename {arch/powerpc/include/asm => include/soc/fsl}/ucc_slow.h 
> (99%)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c43ea88..84b234b 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3743,8 +3743,9 @@ F:      include/linux/fs_enet_pd.h
>  FREESCALE QUICC ENGINE LIBRARY
>  L:   linuxppc-dev@lists.ozlabs.org
>  S:   Orphan
> -F:   arch/powerpc/sysdev/qe_lib/
> -F:   arch/powerpc/include/asm/*qe.h
> +F:   drivers/soc/fsl/qe/
> +F:   include/soc/fsl/*qe*.h
> +F:   include/soc/fsl/*ucc*.h

You forgot to change "Orphan" to "Maintained" and designate a 
maintainer.

Who is going to do the additional work to make this usable on ARM?  
Who is going to merge those patches?

> diff --git a/arch/powerpc/sysdev/qe_lib/Kconfig 
> b/drivers/soc/fsl/qe/Kconfig
> similarity index 50%
> copy from arch/powerpc/sysdev/qe_lib/Kconfig
> copy to drivers/soc/fsl/qe/Kconfig
> index 3c25199..e6b8862 100644
> --- a/arch/powerpc/sysdev/qe_lib/Kconfig
> +++ b/drivers/soc/fsl/qe/Kconfig
> @@ -1,6 +1,16 @@
>  #
>  # QE Communication options
>  #
> +config QUICC_ENGINE
> +     bool "Freescale QUICC Engine (QE) Support"
> +     depends on FSL_SOC && PPC32
> +     select PPC_LIB_RHEAP
> +     select CRC32
> +     help
> +       The QUICC Engine (QE) is a new generation of communications
> +       coprocessors on Freescale embedded CPUs (akin to CPM in older 
> chips).
> +       Selecting this option means that you wish to build a kernel
> +       for a machine with a QE coprocessor.

The whole point of this move is to let the code be used on more than 
just powerpc, so fix the rheap and other obvious PPC dependencies 
first.

-Scott
