From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: IRQ cannot be shared
Date: Fri, 27 Dec 2013 13:43:33 -0500 (EST)
Message-ID: <20131227.134333.1370704464169101441.davem@davemloft.net>
References: <201312202209.04333.sergei.shtylyov@cogentembedded.com>
	<CAGVrzcaUamisoHrW-j5RCt4ph=s0X32uUi7yn7_Wi7=5fxi7tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234Ab3L0Snf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:43:35 -0500
In-Reply-To: <CAGVrzcaUamisoHrW-j5RCt4ph=s0X32uUi7yn7_Wi7=5fxi7tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 20 Dec 2013 10:24:05 -0800

> 2013/12/20 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
>> With the way PHY IRQ handler is implemented (all real handling being pushed to
>> the workqueue and returning IRQ_HANDLED all the time PHY is active), we cannot
>> really claim that PHY IRQ can be shared when calling request_irq().
> 
> Looks good, in the future we might want to be able to let the Ethernet
> MAC driver specify the flags to pass down to request_irq() but this is
> good enough for me for the time being.
> 
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

I really worry that putting this new restriction in place is going to
break a bunch of drivers.

Arguably they are broken, but they are least mostly working right now
and probes will completely fail after this change.

Feel free to allay my concerns, but tossing this into 'net' and
-stable with such a possible risk really concerns me.
