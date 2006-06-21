From: Gerhard Jaeger <g.jaeger@sysgo.com>
Subject: Re: [PATCH 2/3] FS_ENET: use PAL for mii management
Date: Wed, 21 Jun 2006 09:20:36 +0200
Message-ID: <200606210920.37295.g.jaeger@sysgo.com>
References: <20060620145825.24807.310.stgit@vitb.ru.mvista.com> <20060620145840.24807.30296.stgit@vitb.ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vitaly Bordug <vbordug@ru.mvista.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751256AbWFUHUw@vger.kernel.org>
To: linuxppc-embedded@ozlabs.org
In-Reply-To: <20060620145840.24807.30296.stgit@vitb.ru.mvista.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 20 June 2006 16:58, Vitaly Bordug wrote:
> 
> This patch should update the fs_enet infrastructure to utilize
> Phy Abstraction Layer subsystem. Inside there are generic driver rehaul,
> board-specific portion to respect driver changes (for 8272ads and 866ads).
> 
> Signed-off-by: Vitaly Bordug <vbordug@ru.mvista.com>
> ---
> 
>  arch/ppc/platforms/mpc8272ads_setup.c |  154 ++++++----
>  arch/ppc/platforms/mpc866ads_setup.c  |  192 ++++++------
>  arch/ppc/platforms/mpc885ads_setup.c  |  179 ++++--------
>  arch/ppc/syslib/mpc8xx_devices.c      |    8 +
>  arch/ppc/syslib/mpc8xx_sys.c          |    6 
>  arch/ppc/syslib/pq2_devices.c         |    5 
>  arch/ppc/syslib/pq2_sys.c             |    3 
>  drivers/net/fs_enet/Makefile          |    6 
>  drivers/net/fs_enet/fec.h             |   42 +++
>  drivers/net/fs_enet/fs_enet-main.c    |  207 ++++++++-----
>  drivers/net/fs_enet/fs_enet-mii.c     |  507 ---------------------------------
>  drivers/net/fs_enet/fs_enet.h         |   40 ++-
>  drivers/net/fs_enet/mac-fcc.c         |   10 -
>  drivers/net/fs_enet/mac-fec.c         |  132 +--------
>  drivers/net/fs_enet/mac-scc.c         |    4 
>  drivers/net/fs_enet/mii-bitbang.c     |  384 +++++++++++++++----------
>  drivers/net/fs_enet/mii-fec.c         |  243 ++++++++++++++++
>  drivers/net/fs_enet/mii-fixed.c       |   92 ------
>  include/asm-ppc/mpc8260.h             |    1 
>  include/asm-ppc/mpc8xx.h              |    1 
>  include/linux/fs_enet_pd.h            |   50 +--
>  21 files changed, 983 insertions(+), 1283 deletions(-)

[SNIPSNAP]
> diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
> index 24a5e2e..145bf4c 100644
> --- a/drivers/net/fs_enet/mii-bitbang.c
> +++ b/drivers/net/fs_enet/mii-bitbang.c
> @@ -34,6 +34,7 @@
>  #include <linux/mii.h>
>  #include <linux/ethtool.h>
>  #include <linux/bitops.h>
> +#include <linux/platform_device.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/irq.h>
> @@ -41,6 +42,7 @@
>  
>  #include "fs_enet.h"
>  
> +
>  #ifdef CONFIG_8xx
>  static int bitbang_prep_bit(u8 **dirp, u8 **datp, u8 *mskp, int port, int bit)
>  {
> @@ -106,64 +108,25 @@ static int bitbang_prep_bit(u8 **dirp, u
>  }
>  #endif
>  
> -#ifdef CONFIG_8260
> -static int bitbang_prep_bit(u8 **dirp, u8 **datp, u8 *mskp, int port, int bit)
> +static int bitbang_prep_bit(u8 **datp, u8 *mskp,
> +		struct fs_mii_bit *mii_bit)

is it possible, that in case of CONFIG_8xx you'll have two times this 
bitbang_prep_bit() function? 

Gerhard

-- 
Gerhard Jaeger <gjaeger@sysgo.com>            
SYSGO AG                      Embedded and Real-Time Software
www.sysgo.com | www.elinos.com | www.pikeos.com | www.osek.de 
