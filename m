From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix netdev_printk null dereference
Date: Fri, 05 Mar 2010 08:42:40 -0800 (PST)
Message-ID: <20100305.084240.180649738.davem@davemloft.net>
References: <20100305.074335.248610315.davem@davemloft.net>
	<OFD404CD3D.9F15042C-ON802576DD.00595AB8-802576DD.005AD9A8@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57711
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752455Ab0CEQmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 11:42:22 -0500
In-Reply-To: <OFD404CD3D.9F15042C-ON802576DD.00595AB8-802576DD.005AD9A8@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve.Glendinning@smsc.com
Date: Fri, 5 Mar 2010 16:32:03 +0000

> David Miller <davem@davemloft.net> wrote on 05/03/2010 15:43:35:
> 
>> Even more importantly, why does a USB disconnect NULL out the netdev
>> parent device pointer?  Until you actually release this USB device in
>> the driver, the parent pointer should stay there.
> 
> Most of the time it's not nulled out, and the code succesfully prints
> errors as expected, but maybe 1 time in 20 dev.parent is NULL.

I think until the device driver puts it's references and whatnot
of the device it's driving, that parent pointer should be kept
non-NULL.

As long as the netdevice exists and is registered, for example, people
can get at the parent device chain via SYSFS file accesses and
similar.

So it seems to me this is a huge problem waiting to happen anyways and
this netdev_printk() issue is merely making the problem more obvious
:-)
