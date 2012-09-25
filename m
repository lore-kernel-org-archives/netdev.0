From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: removing the timer from cdc-ncm
Date: Tue, 25 Sep 2012 13:18:10 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED59B5@EXDCVYMBSTM006.EQ1STM.local>
References: <6020948.EvS2esPpc0@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "bjorn@mork.no" <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:58884 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755237Ab2IYLTB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 07:19:01 -0400
In-Reply-To: <6020948.EvS2esPpc0@linux-lqwf.site>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum@suse.de]
> 
> here is the patch that does everything I consider theoretically
> necessary to have bundling of frames in usbnet and adapting cdc-ncm to
> it.
> 
> I'd appreciate any review in case I am doing something stupid.
> 

I had a brief look at cdc_ncm and a few corrections needed:
- remove the following:
#include <linux/hrtimer.h>
...
/* Restart the timer, if amount of datagrams is less than given value */
#define	CDC_NCM_RESTART_TIMER_DATAGRAM_CNT	3
#define	CDC_NCM_TIMER_PENDING_CNT		2
#define CDC_NCM_TIMER_INTERVAL			(400UL * NSEC_PER_USEC)
...
In struct cdc_ncm_ctx {
...
	struct hrtimer tx_timer;
	struct tasklet_struct bh;
...

In cdc_ncm_unbind():
	if (hrtimer_active(&ctx->tx_timer))
		hrtimer_cancel(&ctx->tx_timer);

	tasklet_kill(&ctx->bh);

I didn't have time to check the new logic for data path, but I've
tried to run it on Ubuntu 12.04.
Linux host got panic right after data path has been established
(i.e. connected to mobile network). 


Regards,
Alexey
