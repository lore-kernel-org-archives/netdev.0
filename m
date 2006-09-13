From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: netdev tx timeouts
Date: Wed, 13 Sep 2006 14:30:53 +0200
Message-ID: <200609131430.53820.mb@bu3sch.de>
References: <45076C00.2000100@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
In-Reply-To: <45076C00.2000100-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 September 2006 04:25, Larry Finger wrote:
> Michael,
> 
> I still have not gotten a network guru to answer any questions about 
> synchronize_net, but I have been testing the patch below:

I'd say this is racy.
Did you test this on SMP?

> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3169,8 +3169,8 @@ static void bcm43xx_periodic_work_handle
>   		 * be preemtible.
>   		 */
>   		mutex_lock(&bcm->mutex);
> -		netif_stop_queue(bcm->net_dev);
>   		synchronize_net();

A TX handler starts on another CPU.

> +		netif_stop_queue(bcm->net_dev);

It's still running... boom.

>   		spin_lock_irqsave(&bcm->irq_lock, flags);
>   		bcm43xx_mac_suspend(bcm);
>   		if (bcm43xx_using_pio(bcm))
> 
> With the synchronize_net call before the netif_stop_queue as shown, my device 
> has run since last Saturday with no netdev watchdog tx timeouts. Roughly two 
> days of that testing was done at the accelerated rate of 60X normal.
> 
> I still hope to get access to a guru, but if that doesn't happen soon, I'm going 
> to push this change so that it gets into 2.6.19.
> 
> Larry
> 
> 

-- 
Greetings Michael.
