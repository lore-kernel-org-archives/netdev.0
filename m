From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Thu, 17 Jul 2008 15:48:22 +0200
Message-ID: <487F4DA6.6010009@trash.net>
References: <20080717.051726.226040470.davem@davemloft.net>	<487F4327.1000107@trash.net> <20080717.061239.51839567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56710 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756884AbYGQNs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 09:48:26 -0400
In-Reply-To: <20080717.061239.51839567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 17 Jul 2008 15:03:35 +0200
> 
>> Still working my way through the patches, but this one caught my
>> eye (we had this before and it caused quite a few problems).
> 
> Indeed, it's the most delicate change.
> 
> Thanks for the info about all the tricky bits in this area.

One thought that occured to me - we could avoid all the visiblity
issues wrt. dev->qdisc_list by simply getting rid of it :)

If we move the qdisc list from the device to the root Qdisc itself,
it would become invisible automatically as soon as we assign a new
root qdisc to the netdev_queue. Iteration would become slightly
more complicated since we'd have to iterate over all netdev_queues,
but I think it should avoid most of the problems I mentioned
(besides the u32_list thing).


