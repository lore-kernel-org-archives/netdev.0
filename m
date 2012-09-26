From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: removing the timer from cdc-ncm
Date: Wed, 26 Sep 2012 10:57:12 +0200
Message-ID: <9022066.PsM0uBqIB8@linux-lqwf.site>
References: <6020948.EvS2esPpc0@linux-lqwf.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "bjorn-yOkvZcmFvRU@public.gmane.org" <bjorn-yOkvZcmFvRU@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 September 2012 13:18:10 Alexey ORISHKO wrote:
> > -----Original Message-----
> > From: Oliver Neukum [mailto:oneukum-l3A5Bk7waGM@public.gmane.org]
> > 
> > here is the patch that does everything I consider theoretically
> > necessary to have bundling of frames in usbnet and adapting cdc-ncm to
> > it.
> > 
> > I'd appreciate any review in case I am doing something stupid.
> > 
> 
> I had a brief look at cdc_ncm and a few corrections needed:
> - remove the following:
> #include <linux/hrtimer.h>
> ...
> /* Restart the timer, if amount of datagrams is less than given value */
> #define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
> #define	CDC_NCM_TIMER_PENDING_CNT		2
> #define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
> ...
> In struct cdc_ncm_ctx {
> ...
> 	struct hrtimer tx_timer;
> 	struct tasklet_struct bh;
> ...
> 
> In cdc_ncm_unbind():
> 	if (hrtimer_active(&ctx->tx_timer))
> 		hrtimer_cancel(&ctx->tx_timer);
> 
> 	tasklet_kill(&ctx->bh);

Roger

> I didn't have time to check the new logic for data path, but I've
> tried to run it on Ubuntu 12.04.
> Linux host got panic right after data path has been established
> (i.e. connected to mobile network). 

Thank you. Worse than I hoped, but not unexpected. I'll stare at the
code a bit.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
