From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix hostap registration order
Date: Fri, 10 Dec 2010 09:47:47 -0800 (PST)
Message-ID: <20101210.094747.193727608.davem@davemloft.net>
References: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee>
	<20101209.195315.193716225.davem@davemloft.net>
	<alpine.SOC.1.00.1012100918300.15996@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j@w1.fi, netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754150Ab0LJRrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 12:47:20 -0500
In-Reply-To: <alpine.SOC.1.00.1012100918300.15996@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Fri, 10 Dec 2010 09:19:51 +0200 (EET)

>> > In 2.6.37-rc4, hostap_pci init gives a WARNING with backtrace telling 
>> > that netif_stop_queue is called before register_netdev. Fix it by moving 
>> > this call after register_netdev. Removes the warning and seems to work, 
>> > but why is the call to netif_stop_queue needed at all after 
>> > register_netdev?
>> 
>> It should simply not touch the queue state at all at this point.
>> 
>> Your change would add a race.  At the moment the device is registered
>> it can be brought up, and then your code will eroneously modify
>> the queue state.
> 
> OK, I can make a simpler patch for that but I would like to understand 
> the original reasons for having netif_stop_queue there. Just a relict or 
> still somehow important?

I think it was neither.

The queue state is "don't care" at this point, and always has been,
and a lot of drivers had this unnecessary netif_stop_queue() call
there.
