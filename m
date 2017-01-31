From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] r8152: Allocate interrupt buffer as part of struct r8152
Date: Tue, 31 Jan 2017 13:17:17 -0800
Message-ID: <20170131211717.GB21758@roeck-us.net>
References: <1485889577-4389-1-git-send-email-linux@roeck-us.net>
 <1485892411.6360.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:53804 "EHLO
        bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbdAaWLI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 17:11:08 -0500
Content-Disposition: inline
In-Reply-To: <1485892411.6360.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 11:53:31AM -0800, Eric Dumazet wrote:
> On Tue, 2017-01-31 at 11:06 -0800, Guenter Roeck wrote:
> > When unloading the r8152 driver using the 'unbind' sysfs attribute
> > in a system with KASAN enabled, the following error message is seen
> > on a regular basis.
> 
> >  
> >  static int alloc_all_mem(struct r8152 *tp)
> > @@ -1423,10 +1420,6 @@ static int alloc_all_mem(struct r8152 *tp)
> >  	if (!tp->intr_urb)
> >  		goto err1;
> >  
> > -	tp->intr_buff = kmalloc(INTBUFSIZE, GFP_KERNEL);
> > -	if (!tp->intr_buff)
> > -		goto err1;
> > -
> >  	tp->intr_interval = (int)ep_intr->desc.bInterval;
> >  	usb_fill_int_urb(tp->intr_urb, tp->udev, usb_rcvintpipe(tp->udev, 3),
> >  			 tp->intr_buff, INTBUFSIZE, intr_callback,
> 
> This might lead to intr_buff being backed by vzalloc() instead of
> kzalloc() (check alloc_netdev_mqs())
> 
> It looks like it could cause a bug.
> 
I also strongly suspect that it just fixes the symptom, but not the root cause
of the problem.

Thanks,
Guenter
