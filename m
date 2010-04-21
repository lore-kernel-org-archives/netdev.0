From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: Fix possible NULL pointer dereference in ems_usb.c
Date: Tue, 20 Apr 2010 18:05:01 -0700 (PDT)
Message-ID: <20100420.180501.08643239.davem@davemloft.net>
References: <20100420135538.GA1994@bluebox.local>
	<4BCE04D9.2030601@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjk@linutronix.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58509
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754519Ab0DUBE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:04:56 -0400
In-Reply-To: <4BCE04D9.2030601@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Tue, 20 Apr 2010 21:47:37 +0200

> Hans J. Koch wrote:
>> In ems_usb_probe(), a pointer is dereferenced after making sure it is NULL...
>> 
>> This patch replaces dev_err() with printk() to avoid this.
>> 
>> Signed-off-by: "Hans J. Koch" <hjk@linutronix.de>
>> ---
>>  drivers/net/can/usb/ems_usb.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> Index: linux-2.6.34-rc/drivers/net/can/usb/ems_usb.c
>> ===================================================================
>> --- linux-2.6.34-rc.orig/drivers/net/can/usb/ems_usb.c	2010-04-20 15:32:25.000000000 +0200
>> +++ linux-2.6.34-rc/drivers/net/can/usb/ems_usb.c	2010-04-20 15:33:20.000000000 +0200
>> @@ -1006,7 +1006,7 @@
>>  
>>  	netdev = alloc_candev(sizeof(struct ems_usb), MAX_TX_URBS);
>>  	if (!netdev) {
>> -		dev_err(netdev->dev.parent, "Couldn't alloc candev\n");
>> +		printk(KERN_ERR "ems_usb: Couldn't alloc candev\n");
>>  		return -ENOMEM;
>>  	}
> 
> I think "dev_err(&intf->dev, ...)" should be used before
> SET_NETDEV_DEV(netdev, &intf->dev) is called. I see two "dev_err()"
> calls which need to be fixed.

Agreed.
