From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 03 Jan 2011 11:00:42 -0800
Message-ID: <4D221CDA.4000104@intel.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com> <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39544 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365Ab1ACTBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 14:01:07 -0500
In-Reply-To: <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/3/2011 10:47 AM, Tom Herbert wrote:
> I'm not sure why this would be needed.  What is the a advantage in
> making the TX and RX queues match?
>

If the application is affinitized and you are working with RX/TX pairs 
as we have in ixgbe then you can be certain that your buffers are 
staying in the same NUMA node or CPU as the application.  Having them on 
different NUMA nodes can hurt performance for either TX or RX.

The other advantage was that I didn't have to bother with trying to 
reorder the source and destination values when computing an RX hash or a 
TX hash.  I can just call the same function and regardless of direction 
I would get the same hash.  That way I could be guaranteed in a routing 
test that if I was using the RX hash to determine the TX queue that the 
queue number shouldn't change.

I believe the same thing is being accomplished in RPS/TPS via a test for 
the values and swapping them if source is greater than destination.

Thanks,

Alex
