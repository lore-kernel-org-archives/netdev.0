From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 14:45:12 -0700 (PDT)
Message-ID: <20100323.144512.140757007.davem@davemloft.net>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	<1269377667.2915.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55102
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754106Ab0CWVou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 17:44:50 -0400
In-Reply-To: <1269377667.2915.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Mar 2010 21:54:27 +0100

> Quite frankly, the real problem in this case is not the reduced
> throughput, but fact that one cpu can stay a long time doing the xmits
> to device, of skb queued by other cpus. This can hurt latencies a lot,
> for real time threads for example...
> 
> I wonder if ticket spinlocks are not the problem. Maybe we want a
> variant of spinlocks, so that cpu doing transmits can get the lock
> before other cpus...

I want to note that things operate the way they do now
intentionally.

Herbert Xu and Jamal Hadi Salim were active in this area
about 4 years ago.
