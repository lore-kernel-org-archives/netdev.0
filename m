From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 07/26] net/cycx_drv: replace delay_cycx() with msleep_interruptible()
Date: Wed, 09 Mar 2005 15:26:20 -0500
Message-ID: <422F5BEC.5060909@pobox.com>
References: <20050306103258.6FC481E46E@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com, acme@conectiva.com.br,
        janitor@sternwelten.at
To: domen@coderock.org
In-Reply-To: <20050306103258.6FC481E46E@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

domen@coderock.org wrote:
> Use msleep_interruptible() instead of delay_cycx()
> to guarantee the task delays as expected. Remove the prototype and
> definition of delay_cycx().
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Acked-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
> 
> 
>  kj-domen/drivers/net/wan/cycx_drv.c |   24 ++++++++----------------
>  1 files changed, 8 insertions(+), 16 deletions(-)
> 
> diff -puN drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv drivers/net/wan/cycx_drv.c
> --- kj/drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv	2005-03-05 16:09:34.000000000 +0100
> +++ kj-domen/drivers/net/wan/cycx_drv.c	2005-03-05 16:09:34.000000000 +0100
> @@ -56,7 +56,7 @@
>  #include <linux/sched.h>	/* for jiffies, HZ, etc. */
>  #include <linux/cycx_drv.h>	/* API definitions */
>  #include <linux/cycx_cfm.h>	/* CYCX firmware module definitions */
> -#include <linux/delay.h>	/* udelay */
> +#include <linux/delay.h>	/* udelay, msleep */
>  #include <asm/io.h>		/* read[wl], write[wl], ioremap, iounmap */
>  
>  #define	MOD_VERSION	0
> @@ -74,7 +74,6 @@ static int reset_cyc2x(void __iomem *add
>  static int detect_cyc2x(void __iomem *addr);
>  
>  /* Miscellaneous functions */
> -static void delay_cycx(int sec);
>  static int get_option_index(long *optlist, long optval);
>  static u16 checksum(u8 *buf, u32 len);
>  
> @@ -259,7 +258,7 @@ static int memory_exists(void __iomem *a
>  			if (readw(addr + 0x10) == TEST_PATTERN)
>  				return 1;
>  
> -		delay_cycx(1);
> +		msleep_interruptible(1000);

use ssleep_interruptible
