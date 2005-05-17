From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:01:26 -0700
Message-ID: <428A3F86.1020000@us.ibm.com>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>	<20050517.104947.112621738.davem@davemloft.net> <m1zmut7l5q.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmut7l5q.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> "David S. Miller" <davem@davemloft.net> writes:
> 
> 
>>From: Arthur Kepner <akepner@sgi.com>
>>Date: Tue, 17 May 2005 09:18:26 -0700 (PDT)
>>
>>
>>>  1) Fragments must arrive in order (or in reverse order) -
>>>     out of order fragments are dropped. 
>>
>>Even the most simplistic flow over the real internet
>>can get slight packet reordering.
>>
>>Heck, reordering happens on SMP on any network.
>>
>>IP is supposed to be resilient to side effects of network
>>topology, and one such common side effect is packet reordering.
>>It's common, it's fine, and the networking stack deals with it
>>gracefully.  Strict reassembly does not.
> 
> 
> If anything it would be better as a per route flag.
> Then you could set it only for your local network
> where you know Gigabit happens and reordering might
> be avoidable in some cases.
> 
> -Andi
> 
> P.S.: Arthur I think your arguments would have more
> force if you published the test program that demonstrates the
> corruption.

When we first ran into this, the dropping of
out-of-order fragments and overlapped fragments
was considered by us, but we finally did not
employ it precisely because of the ordering
requirement.

This is a fast LAN problem - real internet latencies
don't allow for the wrapping of the id field that fast.

Reordering does happen frequently on an SMP (this was
a non-NAPI environment, NAPI reduces it quite a bit)
so even local gigabit low latency LANs tend to suffer
from it. You really need to be running on a UP to be
entirely safe.

The problem is exacerbated by NFS mount sizes of at least
4K or 8K - thus running NFS over UDP is just an
environment you have to avoid in any case. That doesn't
take care of the other apps, of course.

So you cannot deploy a solution like this over all
interfaces and all routes - perhaps, as Andi says,
a per-route flag (turned on by the sysadmin when
running on a UP or NAPI case) might help. But you'd
have to do this very carefully.

thanks,
Nivedita
