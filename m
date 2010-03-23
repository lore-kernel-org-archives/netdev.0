From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 15:08:12 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F254E49AC69@orsmsx501.amr.corp.intel.com>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<1269377667.2915.25.camel@edumazet-laptop>
 <20100323.144512.140757007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55442 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab0CWWQm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 18:16:42 -0400
In-Reply-To: <20100323.144512.140757007.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 Mar 2010 21:54:27 +0100
> 
>> Quite frankly, the real problem in this case is not the reduced
>> throughput, but fact that one cpu can stay a long time doing the
>> xmits to device, of skb queued by other cpus. This can hurt
>> latencies a lot, for real time threads for example...
>> 
>> I wonder if ticket spinlocks are not the problem. Maybe we want a
>> variant of spinlocks, so that cpu doing transmits can get the lock
>> before other cpus...
> 
> I want to note that things operate the way they do now
> intentionally.
> 
> Herbert Xu and Jamal Hadi Salim were active in this area
> about 4 years ago.

I'll do some digging on this to see what I can find out.  I'm not sure why we would want to do things this way since it seems like the CPU that has qdisc_running is sitting idle due to the fact that the ticket spinlocks have us waiting for all of the other CPU enqueues before we can get around to another dequeue.  It seems like it would be in our best interest to keep qdisc_running going while we are still enqueuing on the other CPUs.

I'll also look into the idea of possibly coming up with a more portable solution such as a priority based spinlock solution.

Thanks,

Alex

