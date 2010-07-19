From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 12:46:01 -0700
Message-ID: <63E39990-7D25-41A5-82F2-DABC53D58A6B@earthlink.net>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:48621 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966496Ab0GSTqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 15:46:08 -0400
In-Reply-To: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom, et al,

		To possibly remove 3-way handshake costs for
		small data transfers a number of years ago, their
		was an experimental RFC that was a Transactional
		TCP, where the SYN, data, and FIN were sent as
		a tuple in the first segmernt.

		If a company has control of the two end systems
		and the intermediate systems, then it should be
		possible for an app to declare in a setsockopt call
		this experimental flow.
		
		Mitchell Erblich
		============

On Jul 19, 2010, at 10:05 AM, Tom Herbert wrote:

> We have been looking at best case TCP latencies that might be achieved
> within a cluster (low loss fabric).  The goal is to have latency
> numbers roughly comparable to that which can be produced using RDMA/IB
> in a low latency configuration  (<5 usecs round trip on netperf TCP_RR
> test with one byte data for directly connected hosts as a starting
> point).  This would be without changing sockets API, fabric, and
> preferably not using TCP offload or a user space stack.
> 
> I think there are at least two techniques that will drive down TCP
> latency: per connection queues and polling queues.  Per connection
> queues (supported by device) should eliminate costs of connection
> look-up, hopefully some locking.  Polling becomes viable as core
> counts on systems increase, and burning a few CPUs for networking
> polling on behalf of very low-latency threads would be reasonable.
> 
> Are there any efforts in progress to integrate per connection queues
> in the stack or integrate polling of queues?
> 
> Thanks,
> Tom
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

