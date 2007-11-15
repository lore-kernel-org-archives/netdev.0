From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Fri, 16 Nov 2007 00:10:46 +0100
Message-ID: <473CD1F6.9030709@o2.pl>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>	<20071115082600.GA2366@ff.dom.local> <20071115102005.0cf46f9a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:57182 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757965AbXKOXIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 18:08:24 -0500
In-Reply-To: <20071115102005.0cf46f9a@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote, On 11/15/2007 07:20 PM:

> On Thu, 15 Nov 2007 09:26:00 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
>> On 15-11-2007 04:38, Stephen Hemminger wrote:
>>> Simple mtu change when device is down.
>>> Fix http://bugzilla.kernel.org/show_bug.cgi?id=9382.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>>>
>>>
>>> --- a/drivers/net/via-velocity.c	2007-10-22 09:38:11.000000000 -0700
>>> +++ b/drivers/net/via-velocity.c	2007-11-14 19:34:30.000000000 -0800
>>> @@ -1963,6 +1963,11 @@ static int velocity_change_mtu(struct ne
>>>  		return -EINVAL;
>>>  	}
>>>  
>>> +	if (!netif_running(dev)) {
>>> +		dev->mtu = new_mtu;
>>> +		return 0;
>>> +	}
>>> +
>>>  	if (new_mtu != oldmtu) {
>>>  		spin_lock_irqsave(&vptr->lock, flags);
>> Shouldn't this latter 'if' be removed now, btw?
> 
> No, it makes sense that if mtu is same, no action need be taken.
> 
> Actually, it would make sense to push the same check up into
> the netdevice core management.

Sure! I was only worried velocity_open() treats dev->mtu
a bit different than velocity_change_mtu(), so eg. after:

velocity_change_mtu() // dev is down
velocity_open()
velocity_change_mtu() // dev is up

with the same mtu, vptr->rx_buf_sz could be different than after:

velocity_open()
velocity_change_mtu() // dev is up

But, probably, I miss someting.

Thanks,
Jarek P.
