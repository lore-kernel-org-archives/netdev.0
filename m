From: hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net v4 3/4] r8152: support stopping/waking tx queue
Date: Wed, 20 Nov 2013 11:28:46 +0800
Message-ID: <9C2E97E7BED9426ABE0FF4F63E12E33D@realtek.com.tw>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com><1384831511-1625-1-git-send-email-hayeswang@realtek.com><1384831511-1625-4-git-send-email-hayeswang@realtek.com> <20131119.152536.146706009595105149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, 'nic_swsd' <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: 'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131119.152536.146706009595105149.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
[...]
> This is racy.
> 
> You have nothing which synchronizes r8152_tx_agg_fill() and 
> rtl8152_start_xmit(),
> therefore:
> 
> > +	if (netif_queue_stopped(tp->netdev))
> > +		netif_wake_queue(tp->netdev);
> > +
> 
> A netif_stop_queue() can occur right after the 
> netif_queue_stopped() check,
> meaning you can end up with the queue being stopped forever 
> and the TX queue
> stuck.

If the situation occurs, it means there is no tx buffer at that time. If the
netif_wake_queue() is called, only one more packet would be queued and the tx
queue would be stopped again after calling rtl8152_start_xmit(). That is, it
is not necessary to wake the queue. Besides, after the tx is completed, another
tasklet would be scheduled if there is any packet which is queued in the list.
That is, the r8152_tx_agg_fill() would be called and the netif_queue_stopped()
would be check againg, so the tx queue would not be stopped forever.
 
Best Regards,
Hayes

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
