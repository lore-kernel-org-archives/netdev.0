From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net/r8169.c - trivial - add KERN_DEBUG to dprintk
 and PFX before KERN_ uses
Date: Tue, 02 Oct 2007 12:57:57 -0400
Message-ID: <47027895.3050208@garzik.org>
References: <1191343038.13170.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35832 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbXJBQ6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 12:58:07 -0400
In-Reply-To: <1191343038.13170.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index c921ec3..40019aa 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -44,7 +44,8 @@
>  		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
>  		#expr,__FILE__,__FUNCTION__,__LINE__);		\
>  	}
> -#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
> +#define dprintk(fmt, args...) \
> +	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
>  #else
>  #define assert(expr) do {} while (0)
>  #define dprintk(fmt, args...)	do {} while (0)
> @@ -1924,7 +1925,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
> -		dprintk(KERN_INFO PFX "Set MAC Reg C+CR Offset 0xE0. "
> +		dprintk("Set MAC Reg C+CR Offset 0xE0. "
>  			"Bit-3 and bit-14 MUST be 1\n");
>  		tp->cp_cmd |= (1 << 14);
>  	}

NAK these, the author clearly prefers his debugging output at KERN_INFO 
level


> @@ -2289,7 +2290,7 @@ static void rtl8169_reinit_task(struct work_struct *work)
>  	ret = rtl8169_open(dev);
>  	if (unlikely(ret < 0)) {
>  		if (net_ratelimit() && netif_msg_drv(tp)) {
> -			printk(PFX KERN_ERR "%s: reinit failure (status = %d)."
> +			printk(KERN_ERR PFX "%s: reinit failure (status = %d)."
>  			       " Rescheduling.\n", dev->name, ret);
>  		}
>  		rtl8169_schedule_work(dev, rtl8169_reinit_task);
> @@ -2321,7 +2322,7 @@ static void rtl8169_reset_task(struct work_struct *work)
>  		netif_wake_queue(dev);
>  	} else {
>  		if (net_ratelimit() && netif_msg_intr(tp)) {
> -			printk(PFX KERN_EMERG "%s: Rx buffers shortage\n",
> +			printk(KERN_EMERG PFX "%s: Rx buffers shortage\n",
>  			       dev->name);
>  		}

these are fixes, and should be in a separate patch


