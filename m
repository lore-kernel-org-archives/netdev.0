From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Fixes memory leak in ibm_newemac ethernet
	driver
Date: Wed, 02 Jul 2008 15:46:00 +1000
Message-ID: <1214977560.21182.35.camel@pasglop>
References: <1214225712-25882-1-git-send-email-sr@denx.de>
	 <1214263310.8011.280.camel@pasglop>
	 <1946a170807012145v6e6d629cvea443f2b8462d708@mail.gmail.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: SathyaNarayanan <sathyan@teamf1.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51159 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750826AbYGBFqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 01:46:14 -0400
In-Reply-To: <1946a170807012145v6e6d629cvea443f2b8462d708@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Actually the meachanism of stopping the queue and starting it is
> already there.  But even then due to some sync issue between the poll
> routine and xmit, we were resulted in using the slots of skb which was
> not actually got freed before. 
> I agree this could a bug , Since its not is not clear why buffers are
> not getting transferred timely?. But to handle this we should have a
> work around otherwise system may go out of memory. If we go for
> stopping the queue in these scenario also ( Where a unfreed skbs slot
> has been assigned  to another ), Then kernel may call tx timeout, And
> reset the driver. In that case handelling this special case here could
> lead us better performance as compared to stopping the queue
> Let me know your comments.

Well, if we have a bug, we need to fix it. ie, understand how it is that
the existing mechanism to stop the queue doesn't work, and prevent xmit
from overwriting a non-clear transmit slot (possibly displaying an error
to help us track down the bug).

I'll have to dig a bit, I'll see if I can find some time tomorrow.

Cheers,
Ben.



