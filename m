From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] uninitialized variable in prism54 isl38xx_trigger_device
Date: Thu, 16 Jun 2005 19:52:04 -0400
Message-ID: <43e72e8905061616527858ebd6@mail.gmail.com>
References: <20050525231651.GA21816@suse.de>
Reply-To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        prism54-private@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
In-Reply-To: <20050525231651.GA21816@suse.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sure, why not. This has been applied to prism54 svn tree.

On 5/25/05, Olaf Hering <olh@suse.de> wrote:
> 
> drivers/net/wireless/prism54/isl_38xx.c:131: warning: 'current_time.tv_sec' is used uninitialized in this function
> drivers/net/wireless/prism54/isl_38xx.c:131: warning: 'current_time.tv_usec' is used uninitialized in this function
> 
> Signed-off-by: Olaf Hering <olh@suse.de>
> Index: linux-2.6.12-rc5-olh/drivers/net/wireless/prism54/isl_38xx.c
> ===================================================================
> --- linux-2.6.12-rc5-olh.orig/drivers/net/wireless/prism54/isl_38xx.c
> +++ linux-2.6.12-rc5-olh/drivers/net/wireless/prism54/isl_38xx.c
> @@ -112,10 +112,10 @@ isl38xx_handle_wakeup(isl38xx_control_bl
>  void
>  isl38xx_trigger_device(int asleep, void __iomem *device_base)
>  {
> -       struct timeval current_time;
>         u32 reg, counter = 0;
> 
>  #if VERBOSE > SHOW_ERROR_MESSAGES
> +       struct timeval current_time;
>         DEBUG(SHOW_FUNCTION_CALLS, "isl38xx trigger device\n");
>  #endif
> 
> @@ -126,11 +126,11 @@ isl38xx_trigger_device(int asleep, void
>                 do_gettimeofday(&current_time);
>                 DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
>                       current_time.tv_sec, (long)current_time.tv_usec);
> -#endif
> 
>                 DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
>                       current_time.tv_sec, (long)current_time.tv_usec,
>                       readl(device_base + ISL38XX_CTRL_STAT_REG));
> +#endif
>                 udelay(ISL38XX_WRITEIO_DELAY);
> 
>                 reg = readl(device_base + ISL38XX_INT_IDENT_REG);
> @@ -148,10 +148,12 @@ isl38xx_trigger_device(int asleep, void
>                                 counter++;
>                         }
> 
> +#if VERBOSE > SHOW_ERROR_MESSAGES
>                         DEBUG(SHOW_TRACING,
>                               "%08li.%08li Device register read %08x\n",
>                               current_time.tv_sec, (long)current_time.tv_usec,
>                               readl(device_base + ISL38XX_CTRL_STAT_REG));
> +#endif
>                         udelay(ISL38XX_WRITEIO_DELAY);
> 
>  #if VERBOSE > SHOW_ERROR_MESSAGES
>
