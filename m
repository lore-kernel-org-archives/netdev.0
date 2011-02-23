From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 15:54:51 -0800 (PST)
Message-ID: <20110223.155451.70202591.davem@davemloft.net>
References: <20110223230844.GA16476@linuxace.com>
	<20110223.151357.245408084.davem@davemloft.net>
	<1298504269.2211.503.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, andy@greyhouse.net, netdev@vger.kernel.org,
	fubar@us.ibm.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60194
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753289Ab1BWXyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 18:54:15 -0500
In-Reply-To: <1298504269.2211.503.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 23 Feb 2011 23:37:49 +0000

> On Wed, 2011-02-23 at 15:13 -0800, David Miller wrote:
>> From: Phil Oester <kernel@linuxace.com>
>> Date: Wed, 23 Feb 2011 15:08:44 -0800
>> 
>> > On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
>> >> + * destination queue.  Using a helper function skips the a call to
>> > 
>> > s/the a/a/ or s/the a/the/
>> > 
>> >> +     while (txq >= dev->real_num_tx_queues) {
>> >> +             /* let the user know if we do not have enough tx queues */
>> >> +             if (net_ratelimit())
>> >> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
>> >> +                                " setting module option tx_queues > %d.",
>> >> +                                dev->name, txq, dev->real_num_tx_queues);
>> >> +             txq -= dev->real_num_tx_queues;
>> >> +     }
>> > 
>> > Think this would be better as a WARN_ONCE, as otherwise syslog will still
>> > get flooded with this - even when ratelimited.  See get_rps_cpu in 
>> > net/core/dev.c as an example.o
>> 
>> Agreed.
> 
> This shouldn't WARN at all.  It is perfectly valid (though non-optimal)
> to have different numbers of queues on two different multiqueue devices.

That's also a good point.
