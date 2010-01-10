From: David Miller <davem@davemloft.net>
Subject: Re: problem with kernel ipconfig over usb ethernet on v.2.6.33-rc3
Date: Sun, 10 Jan 2010 13:38:48 -0800 (PST)
Message-ID: <20100110.133848.200626367.davem@davemloft.net>
References: <cabda6421001100027u1ca339a6ka46470431caa21ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chripell@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437Ab0AJVij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 16:38:39 -0500
In-Reply-To: <cabda6421001100027u1ca339a6ka46470431caa21ba@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: christian pellegrin <chripell@gmail.com>
Date: Sun, 10 Jan 2010 09:27:48 +0100

> Hi,
> 
> I noticed that kernel IP auto-configuration is not usable for
> USB-ethenet dongles on newer kernel because it starts before the USB
> devices are found (perhaps as a consequence of parallelization of
> kernel boot; the built-in delay of 500ms is not enough).I'm using the
> following patch (with a command line parameter ipconfigdelay=10) to
> solve this situation, but it's a shameless cut & paste from rootdelay.
> Is there any better solution or I'm just missing something?

How long does it actually take for the USB ethernet device
to become visible at this point?

Is 2 seconds enough?  For example.

If so, let's just change CONF_PRE_OPEN to "2" and change
msleep() to ssleep().

It's rediculious to require that users learn about obscure
kernel command line options in order for basic functionality
to work properly.
