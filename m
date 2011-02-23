From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 15:13:57 -0800 (PST)
Message-ID: <20110223.151357.245408084.davem@davemloft.net>
References: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
	<20110223230844.GA16476@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, fubar@us.ibm.com
To: kernel@linuxace.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209Ab1BWXNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 18:13:21 -0500
In-Reply-To: <20110223230844.GA16476@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>
Date: Wed, 23 Feb 2011 15:08:44 -0800

> On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
>> + * destination queue.  Using a helper function skips the a call to
> 
> s/the a/a/ or s/the a/the/
> 
>> +     while (txq >= dev->real_num_tx_queues) {
>> +             /* let the user know if we do not have enough tx queues */
>> +             if (net_ratelimit())
>> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
>> +                                " setting module option tx_queues > %d.",
>> +                                dev->name, txq, dev->real_num_tx_queues);
>> +             txq -= dev->real_num_tx_queues;
>> +     }
> 
> Think this would be better as a WARN_ONCE, as otherwise syslog will still
> get flooded with this - even when ratelimited.  See get_rps_cpu in 
> net/core/dev.c as an example.o

Agreed.
