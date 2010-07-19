From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Very low latency TCP for clusters
Date: Mon, 19 Jul 2010 11:28:53 -0700
Message-ID: <4C449965.9050202@us.ibm.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47137 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934806Ab0GSS3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 14:29:01 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6JIAxi3002094
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 14:10:59 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6JISt7R094828
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 14:28:55 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6JISsmL009820
	for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 12:28:54 -0600
In-Reply-To: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> We have been looking at best case TCP latencies that might be achieved
> within a cluster (low loss fabric).  The goal is to have latency
> numbers roughly comparable to that which can be produced using RDMA/IB
> in a low latency configuration  (<5 usecs round trip on netperf TCP_RR
> test with one byte data for directly connected hosts as a starting
> point).  This would be without changing sockets API, fabric, and
> preferably not using TCP offload or a user space stack.

Over what media are you doing this? 10gbe? gbe? Whatever numbers
I've seen for latency have been superior on IB, and I'd be very
interested in any effort to get lower latencies over other transport.

> I think there are at least two techniques that will drive down TCP
> latency: per connection queues and polling queues.  Per connection
> queues (supported by device) should eliminate costs of connection
> look-up, hopefully some locking.  Polling becomes viable as core
> counts on systems increase, and burning a few CPUs for networking
> polling on behalf of very low-latency threads would be reasonable.

Have you got any profiling data that captures where your
particular latencies are? Also, have you tried a real-time
kernel?

thanks,
Nivedita
