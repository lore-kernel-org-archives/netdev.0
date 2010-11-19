From: David Miller <davem@davemloft.net>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 14:08:18 -0800 (PST)
Message-ID: <20101119.140818.242132853.davem@davemloft.net>
References: <4CE6ED09.70602@hp.com>
	<20101119.135213.15239226.davem@davemloft.net>
	<4CE6F2FD.8080301@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758383Ab0KSWHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 17:07:54 -0500
In-Reply-To: <4CE6F2FD.8080301@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 19 Nov 2010 13:58:21 -0800

> David Miller wrote:
>> From: Rick Jones <rick.jones2@hp.com>
>> Date: Fri, 19 Nov 2010 13:32:57 -0800
>> 
>>>I suppose then one would be able to track the consumer pointer (on tx)
>>>to "know" that certain data had been ACKed by the remote?  For TCP
>>>anyway - and assuming there wouldn't be a case where TCP might copy
>>>the data out of the ring and assert "completion."
>> Yes, that's implicit in his design, the kernel manages the consumer
>> pointer in the ring and this is how userspace can see when ring
>> entries
>> are reusable.
> 
> But does one really want to lock-in that the update to the consumer
> pointer means the data has been ACKed by the remote (or I suppose that
> DMA have completed if it were UDP)?

I think the ACK (or for UDP, the kfree_skb() after TX completes) should
move the consumer pointer.  Otherwise you have to copy, and the ACKs
do not clock the sender process properly.

But you do bring up an interesting point about TX buffer space sizing.

This whole scheme currently seems to completely ignore buffer size
auto-tuning done by TCP, and that won't fly I think. :-)

The whole point is to make it so that applications do not need to know
about that aspect of buffering at all.  With the current mmap design
we're back to the stone ages where the app essentially has to pick an
explicit send buffer size.



