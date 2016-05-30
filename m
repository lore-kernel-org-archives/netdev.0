From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: Re: usbnet: smsc95xx: fix link detection for disabled
 autonegotiation
Date: Mon, 30 May 2016 22:07:42 +0200
Message-ID: <1464638862.1883.31.camel@googlemail.com>
References: <1464228407.5421.34.camel@googlemail.com>
	 <20160529.223010.1702681088925445499.davem@davemloft.net>
Reply-To: chf.fritz@googlemail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36553 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933361AbcE3UHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 16:07:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id q62so25868803wmg.3
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 13:07:45 -0700 (PDT)
In-Reply-To: <20160529.223010.1702681088925445499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-05-29 at 22:30 -0700, David Miller wrote:
> From: Christoph Fritz <chf.fritz@googlemail.com>
> Date: Thu, 26 May 2016 04:06:47 +0200
> 
> > @@ -1695,6 +1745,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
> >  
> >  	/* do this first to ensure it's cleared even in error case */
> >  	pdata->suspend_flags = 0;
> > +	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);
> 
> Why are you not cancelling this delayed work in the suspend routine of
> the driver?

I'm doing this:
+       if (pdata->suspend_flags != 0)
+               return;

inside the "worker-function" so that schedule_delayed_work() is not
called again.

Should I explicitly cancel_delayed_work() inside suspend() too?
