From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 08:04:00 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520074848.U40843@shell.cyberus.ca>
References: <20030519212209.P39592@shell.cyberus.ca> <20030519.182410.10302536.davem@redhat.com>
 <20030519220409.V39658@shell.cyberus.ca> <20030519.234624.123976229.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030519.234624.123976229.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 19 May 2003, David S. Miller wrote:

> I found a description of this thing on Cisco's web site.  Amusingly it
> seems to contradict itself, it says that the CEF FIB is fully
> populated and has a 1-to-1 correspondance to the routing table yet it
> says that the first access to some destination is what creates
> CEF entries.
>

It seems to be done at interupt level sort of like Linux fast switching
(not to be confused with CISCO fast switching); however, unlike Linux fast
switching which looks up based on dst cache, they do lookups on a
FIB with already nexthop entries (sort of like the hh cache we have).
Theres something akin to a user land process which makes sure the
neighbors are resolved all the time - most routing protocols stacks
already do this today with BGP. I dont think Zebra does.
What i am wondering is what if they have to do more than routing? Dont
they end up with same (if not worse) effect?

Having said all the above, i think it would be worth seeing what the
effect of improving the slow path is (make it a multi-way trie).
Actually before that someone needs to prove slow path is slow ;->
Note: It may make sense that we have options to totaly remove
the cache lookups if necessary - noone has proved a need for it at this
point.

cheers,
jamal
