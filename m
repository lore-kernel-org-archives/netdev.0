From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] net: Saner thash_entries default with much memory
Date: Tue, 30 Oct 2007 21:42:05 +0100
Message-ID: <200710302142.05753.ak@suse.de>
References: <200710261721.32019.jdelvare@suse.de> <20071026153416.GA23491@bingen.suse.de> <20071030.005758.184980120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60689 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753634AbXJ3UpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 16:45:21 -0400
In-Reply-To: <20071030.005758.184980120.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Next, machines that service that many sockets typically have them
> mostly with full transmit queues talking to a very slow receiver at
> the other end. 

Not sure -- there are likely use cases with lots of idle but connected 
sockets.

Also the constraint here is not really how many sockets are served,
but how well the hash function manages to spread them in the table.. I don't
have good data on that.

But still (512 * 1024) sounds reasonable because e.g. in the lots
of idle socket case you're probably fine with the hash chains
having more than one entry worst case because a small working
set will fit in cache and as long as the chains do not end up
very long walking in cache of a short list will be still fast enough.

> So to me (512 * 1024) is a very reasonable limit and (with lockdep
> and spinlock debugging disabled) this makes the EHASH table consume
> 8MB on UP 64-bit and ~12MB on SMP 64-bit systems.

I still have my doubts it makes sense to have an own lock for each bucket. It 
would be probably better to just divide the hash value through a factor
again and then use that to index a smaller lock only table.

-Andi
