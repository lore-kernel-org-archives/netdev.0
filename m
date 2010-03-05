From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 5 Mar 2010 16:32:03 +0000
Message-ID: <OFD404CD3D.9F15042C-ON802576DD.00595AB8-802576DD.005AD9A8@smsc.com>
References: <20100305.074335.248610315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:57149 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752877Ab0CEQcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 11:32:11 -0500
In-Reply-To: <20100305.074335.248610315.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 05/03/2010 15:43:35:

> It seems to me that really you only need this parent NULL check where
> you notice the USB control operation failed and want to print a
> message about that.
> 
> That should cover all the necessary cases shouldn't it?

That's the easily reproducible case - during initialisation there are
a lot of register reads and writes, so it's quite easy to trigger by
manually unplugging ~500ms after connection. In this case usbnet is
still in usbnet_probe.

Theoretically though, this device could be disconnected at any time,
and there are other places in the code where we print messages not
triggered by a usb failure (for example set_multicast).  Could it
be possibly unsafe to call netdev_printk here?

> Even more importantly, why does a USB disconnect NULL out the netdev
> parent device pointer?  Until you actually release this USB device in
> the driver, the parent pointer should stay there.

Most of the time it's not nulled out, and the code succesfully prints
errors as expected, but maybe 1 time in 20 dev.parent is NULL.
