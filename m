From: David Miller <davem@davemloft.net>
Subject: Re: usbnet: smsc95xx: fix link detection for disabled
 autonegotiation
Date: Tue, 31 May 2016 14:22:45 -0700 (PDT)
Message-ID: <20160531.142245.1824632159286621339.davem@davemloft.net>
References: <1464228407.5421.34.camel@googlemail.com>
	<20160529.223010.1702681088925445499.davem@davemloft.net>
	<1464638862.1883.31.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: chf.fritz@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbcEaVWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 17:22:46 -0400
In-Reply-To: <1464638862.1883.31.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Mon, 30 May 2016 22:07:42 +0200

> On Sun, 2016-05-29 at 22:30 -0700, David Miller wrote:
>> From: Christoph Fritz <chf.fritz@googlemail.com>
>> Date: Thu, 26 May 2016 04:06:47 +0200
>> 
>> > @@ -1695,6 +1745,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
>> >  
>> >  	/* do this first to ensure it's cleared even in error case */
>> >  	pdata->suspend_flags = 0;
>> > +	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);
>> 
>> Why are you not cancelling this delayed work in the suspend routine of
>> the driver?
> 
> I'm doing this:
> +       if (pdata->suspend_flags != 0)
> +               return;
> 
> inside the "worker-function" so that schedule_delayed_work() is not
> called again.

Aha, I didn't catch that.

Applied, thanks.
