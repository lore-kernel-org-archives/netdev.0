From: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Sun, 21 Sep 2008 12:43:32 -0700
Message-ID: <20080921124332.67ddc13a@infradead.org>
References: <20080921172316.GA6306@2ka.mipt.ru>
	<20080921110422.1d010b96@infradead.org>
	<20080921182835.GA11473@2ka.mipt.ru>
	<20080921113513.16677c4e@infradead.org>
	<20080921190050.GA20484@2ka.mipt.ru>
	<1222024444.3023.53.camel@johannes.berg>
	<20080921193809.GA8735@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921193809.GA8735-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Sep 2008 23:38:09 +0400
Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org> wrote:

> 
> As I pointed, I can rewrite the whole driver's initialization process,
> so that it looked like init/wait/exit loop, which can be processed at
> the module load and when fatal interrupt fires. 

yes please do this.

> 
> I do hope this will result in a progress. Arjan, do you aggree to add
> this patch to the current tree?
> 
> diff --git a/drivers/net/wireless/ipw2100.c
> b/drivers/net/wireless/ipw2100.c index 19a401c..9a7b64c 100644
> --- a/drivers/net/wireless/ipw2100.c
> +++ b/drivers/net/wireless/ipw2100.c
> @@ -206,6 +206,8 @@ MODULE_PARM_DESC(disable, "manually disable the
> radio (default 0 [radio on])"); 
>  static u32 ipw2100_debug_level = IPW_DL_NONE;
>  
> +static int ipw2100_max_fatal_ints = 10;
> +
>  #ifdef CONFIG_IPW2100_DEBUG
>  #define IPW_DEBUG(level, message...) \
>  do { \
> @@ -3174,6 +3176,10 @@ static void ipw2100_irq_tasklet(struct
> ipw2100_priv *priv) if (inta & IPW2100_INTA_FATAL_ERROR) {
>  		printk(KERN_WARNING DRV_NAME
>  		       ": Fatal interrupt. Scheduling firmware
> restart.\n");
> +		WARN_ON(1);
> +
> +		BUG_ON(ipw2100_max_fatal_ints-- <= 0);

BUG_ON in interrupt context is just extremely hostile, since it means
the box is dead.

also I would suggest using WARN_ON_ONCE() 

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
