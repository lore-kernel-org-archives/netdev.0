From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 05 Mar 2010 07:43:35 -0800 (PST)
Message-ID: <20100305.074335.248610315.davem@davemloft.net>
References: <20100305.063909.26489418.davem@davemloft.net>
	<OF33DF005A.0C447DF0-ON802576DD.00538FB8-802576DD.00552375@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33118
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754099Ab0CEPnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 10:43:16 -0500
In-Reply-To: <OF33DF005A.0C447DF0-ON802576DD.00538FB8-802576DD.00552375@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Fri, 5 Mar 2010 15:29:41 +0000

> The failure I'm seeing is caused when the usb device is disconnected.
> smsc95xx detects that a pending USB control operation failed
> and tries to print a message via netdev_printk to report this.
> 
> Unfortunately, something else (the USB subsystem?) has already set
> parent to null at this time so the netdev_printk causes a null 
> dereference.
> 
> So netdev_printk suddenly changes from safe to use to unsafe to use?

It seems to me that really you only need this parent NULL check where
you notice the USB control operation failed and want to print a
message about that.

That should cover all the necessary cases shouldn't it?

Even more importantly, why does a USB disconnect NULL out the netdev
parent device pointer?  Until you actually release this USB device in
the driver, the parent pointer should stay there.
