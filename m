From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Tue, 07 Oct 2014 12:08:44 -0400 (EDT)
Message-ID: <20141007.120844.1942274261809860374.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D174C5C35@AcuExch.aculab.com>
	<20141007.114341.1417644866461362364.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D174C621F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, john.fastabend@gmail.com, dborkman@redhat.com,
	fw@strlen.de, gerlitz.or@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbaJGQIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:08:47 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C621F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 7 Oct 2014 15:59:35 +0000

> From: David 
>> From: David Laight <David.Laight@ACULAB.COM>
>> Date: Tue, 7 Oct 2014 09:27:03 +0000
>> 
>> > That is (probably) the only scheme that stops the application
>> > accessing random parts of physical memory.
>> 
>> I don't know where this claim keeps coming from, it's false.
>> 
>> The application has to attach memory to the ring, and then the
>> ring can only refer to that memory for the duration of the
>> session.
>> 
>> There is no way that the user can program the address field of the
>> descriptors to point at arbitrary physical memory locations.
>> 
>> There is protection and control.
> 
> I got the impression that the application was directly writing the ring
> structure that the ethernet mac hardware uses to describe tx and rx buffers.
> (ie they are mapped read-write into userspace).
> Unless you have a system where you can limit the physical memory
> ranges accessible to the mac hardware, I don't see how you can stop
> the application putting rogue values into the ring.
> 
> Clearly I'm missing something in my quick read of the change.

No, I think I misunderstood, and apparently the Mellanox driver allows
the user to crap into arbitrary physical memory too.

All of this garbage must get fixed and this feature is a non-starter
until there is control over the memory the rings can point ti.
