From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmveth: Increase default copybreak limits to 2k
Date: Thu, 21 Oct 2010 10:17:46 -0500
Message-ID: <20101021151746.GB5567@linux.vnet.ibm.com>
References: <20101021143753.GA5567@linux.vnet.ibm.com>
 <20101021.074525.71113963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42451 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab0JUPRv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 11:17:51 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9LF1jjs003830
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 11:01:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9LFHnql962690
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 11:17:50 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9LFHnVO024268
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 11:17:49 -0400
Content-Disposition: inline
In-Reply-To: <20101021.074525.71113963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller (davem@davemloft.net) wrote:
> From: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> > Increase the copybreak limits for rx and tx from 128 bytes
> > to 2048 bytes. These limits were added by commits
> > 8d86c61ae41d9068fd5e5cc01a4abd53c4fe3ab5 and
> > c08cc3ccebd46dce44d13a8ce81d249e687eeb8a to make use of a
> > bounce buffer for packets below 128 bytes.  This avoids
> > tearing down and creating a TCE entry.
> > 
> > Performance testing shows that this default limit can be
> > increased from 128 to 2048 for both rx and tx copybreak.
> > This resulted in ~10% throughput increase for for packets
> > that fit this limit without affecting performance for larger
> > packets.
> > 
> > Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> For a default MTU of 1500 this means the copybreak will
> never be used.
> 
> This makes absolutely no sense, are you doing these tests
> with Jumbo frames?

The value of copybreak is the point where we stop using the bounce
buffer and start to copy data to new buffers; having the overhead of
additional TCE entry setup/teardown.  For the default MTU of 1500,
increasing the copybreak value to 2k will result in all packets using
the bounce buffer now.  Expanding the use of the bounce buffer up to 2k
with the default MTU resulted in ~10% throughput improvement.

This was also tested with jumbo frames to verify that larger than
2k we don't use the bounce buffer and that there is no performance
regression.

I can repost the patch with these clarifications in the log message
if you would like.

--Rob Jennings
