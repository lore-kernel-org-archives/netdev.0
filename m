From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Mon, 07 Mar 2016 23:07:37 -0500 (EST)
Message-ID: <20160307.230737.1738396720590983620.davem@davemloft.net>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
	<20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
	<23389.1457390714@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <23389.1457390714@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 07 Mar 2016 22:45:14 +0000

> David Miller <davem@davemloft.net> wrote:
> 
>> I know you put a lot of time and effort into this, but I want to strongly
>> recommend against a garbage collected hash table for anything whatsoever.
>> 
>> Especially if the given objects are in some way created/destroyed/etc. by
>> operations triggerable remotely.
>> 
>> This can be DoS'd quite trivially, and that's why we have removed the ipv4
>> routing cache which did the same.
> 
> Hmmm...  You have a point.  What would you suggest instead?  At least with the
> common object cache code I have, I might be able to just change that.

Objects that are used for correct operation have no easily recyclable
property, you must hold onto them.  There has to be a set of resources
held and consumed at both endpoints for it to work properly ("I can't
DoS you without DoS'ing myself").

Where reclaimable tables work is for stuff that is near zero cost to
reconstitute.  A good example is the TCP metrics table.  When a TCP
metrics entry is reclaimed, it's not like we have to renegotiate a
security context when we try to talk to that end-host again.

If the concept of these open-ended objects is a fundamental aspect of
the protocol.... that's a serious shortcoming of RXRPC.
