From: David Miller <davem@davemloft.net>
Subject: Re: usbnet: smsc95xx: fix link detection for disabled
 autonegotiation
Date: Sun, 29 May 2016 22:30:10 -0700 (PDT)
Message-ID: <20160529.223010.1702681088925445499.davem@davemloft.net>
References: <1464228407.5421.34.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: chf.fritz@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcE3FaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 01:30:11 -0400
In-Reply-To: <1464228407.5421.34.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Thu, 26 May 2016 04:06:47 +0200

> @@ -1695,6 +1745,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
>  
>  	/* do this first to ensure it's cleared even in error case */
>  	pdata->suspend_flags = 0;
> +	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);

Why are you not cancelling this delayed work in the suspend routine of
the driver?
