From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:40:07 -0700 (PDT)
Message-ID: <20070510.144007.62663063.davem@davemloft.net>
References: <46435412.50800@hp.com>
	<OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, johnpol@2ka.mipt.ru, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754996AbXEJVkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:40:05 -0400
In-Reply-To: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 10 May 2007 14:27:56 -0700

> The word "small" is coming up a lot in this discussion, and
> I think packet size really has nothing to do with it. Multiple
> streams generating packets of any size would benefit; the
> key ingredient is a queue length greater than 1.
> 
> I think the intent is to remove queue lock cycles by taking
> the whole list (at least up to the count of free ring buffers)
> when the queue is greater than one packet, thus effectively
> removing the lock expense for n-1 packets.

Right.

But I think it's critical to do two things:

1) Do this when netif_wake_queue() is triggers and thus the
   TX is locked already.

2) Have some way for the driver to say how many free TX slots
   there are in order to minimize if not eliminate requeueing
   during this batching thing.

If you drop the TX lock, the number of free slots can change
as another cpu gets in there queuing packets.

I know there are some hardware workarounds that require using
more TX ring buffer slots and are usually necessary, which
makes %100 accurate indication of free slots not possible.
