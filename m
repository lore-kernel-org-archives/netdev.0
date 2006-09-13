From: Bob Heise <heise2k@gmail.com>
Subject: netdev tx timeout
Date: Tue, 12 Sep 2006 23:06:15 -0400
Message-ID: <200609122306.15664.heise2k@gmail.com>
Reply-To: heise2k@gmail.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:61234 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751532AbWIMDwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 23:52:46 -0400
Received: by wx-out-0506.google.com with SMTP id s14so2233761wxc
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2006 20:52:46 -0700 (PDT)
To: Larry.Finger@lwfinger.net, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Michael,
>
> I still have not gotten a network guru to answer any questions about
> synchronize_net, but I have been testing the patch below:
>
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
> +		netif_stop_queue(bcm->net_dev);
>   		spin_lock_irqsave(&bcm->irq_lock, flags);
>   		bcm43xx_mac_suspend(bcm);
>   		if (bcm43xx_using_pio(bcm))
>
> With the synchronize_net call before the netif_stop_queue as shown, my
> device has run since last Saturday with no netdev watchdog tx timeouts.
> Roughly two days of that testing was done at the accelerated rate of 60X
> normal.
>
> I still hope to get access to a guru, but if that doesn't happen soon, I'm
> going to push this change so that it gets into 2.6.19.
>
> Larry

Larry,

I am running a bcm4306, and got hit by this netdev tx timeout problem. I have 
upgraded to the latest wireless-2.6 git and wanted to test out the above 
patch. What was the 60x normal testing tweak you made?

Thanks,
Bob Heise
