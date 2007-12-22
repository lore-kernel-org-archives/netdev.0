From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Reduce locking in TX path of forcedth driver
Date: Fri, 21 Dec 2007 22:51:26 -0500
Message-ID: <476C89BE.9050700@garzik.org>
References: <20071222014134.A28994161A0@localhost> <20071221185435.2884f118@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49095 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbXLVDvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 22:51:33 -0500
In-Reply-To: <20071221185435.2884f118@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(Stephen, your mailer is snipping CC's, please fix....)

(Tom, you failed to CC the maintainer at NVIDIA, please fix...)

Stephen Hemminger wrote:
> On Fri, 21 Dec 2007 17:41:34 -0800 (PST)
> therbert@google.com (Tom Herbert) wrote:
> 
>> Reduce the amount of locking in the TX path.  Instead of using both netif_tx_lock and dev->priv->lock on transmitting, a single private lock (dev->priv->tx_lock) is used.  This method is similar to that of the e1000 driver, including the logic to stop the queue in the start xmit functions, and the logic to wake the queue in the TX done functions.  We see some performance improvement with this patch.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
> 
> 
>>  
>> +	spin_lock_init(&np->tx_lock);
>> +
>> +	dev->features |= NETIF_F_LLTX;
>> +
> 
> NAK - lockless transmit is not desirable for real devices.
> 
> use netif_tx_lock() instead of your private lock

True enough, though also note that (a) the forcedeth driver has many 
problems in the locking department, and (b) anyone interested in working 
on this problem should start with the existing -- working -- work in 
progress that has already been posted to netdev a couple times:

     Branch 'fe' of
     git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

forcedeth (as it exists unmodified in upstream) tries so hard to be 
lockless...  that it winds up taking a ton of locks all over the place, 
completely failing to reach its own goal.

	Jeff



