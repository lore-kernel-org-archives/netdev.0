From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Mon, 8 Sep 2008 14:17:42 +0100
Message-ID: <OF4A15F580.3A8DD1DE-ON802574BE.0047659A-802574BE.0049088D@smsc.com>
References: <20080906150932.630C.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	ian.saturley@smsc.com, netdev@vger.kernel.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2549 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751811AbYIHNdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 09:33:13 -0400
In-Reply-To: <20080906150932.630C.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Masakazu,

Thanks for the valuable feedback, I'll re-submit another attempt shortly.

> > +static int smsc95xx_eeprom_is_busy(struct usbnet *dev)
> > +{
> > +   u32 val;
> > +   int i;
> > +
> > +   /* 40ms total */
> As smsc95xx_read_reg() uses the synchronous urb call and AFAIR ehci
> would defer the interrupts until 8 micro-frames by default, so I guess 
this
> loop would take more than 40ms?
> 
> > +   for (i = 0; i < 1000; i++) {
> > +      smsc95xx_read_reg(dev, E2P_CMD, &val);
> > +      if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
> > +         break;
> > +      udelay(40);
> > +   }

Yes, if no EEPROM is connected (or if the device has timed out) the loop 
will
run for longer than 40ms.  After 30ms the device TIMEOUT bit should go 
high,
so we should only hit the end of the loop counter if something is quite 
broken.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
