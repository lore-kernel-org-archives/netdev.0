From: jamal <hadi@cyberus.ca>
Subject: Re: A bug in the Kernel?
Date: 12 Apr 2005 09:18:23 -0400
Message-ID: <1113311902.1961.59.camel@jzny.localdomain>
References: <3558.193.232.114.87.1113309101.squirrel@mx>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: itkes@imec.msu.ru
In-Reply-To: <3558.193.232.114.87.1113309101.squirrel@mx>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex,

I think i tried to respond to you before but the message may have not
made it through.
This is expected behavior i.e i wouldnt exactly call it a bug - rather
it is a design tradeoff. You are correct, this behavior exists every
where with netlink not just with policy routes.

The only way you can protect app A from app B is to hold a lock until
the operation is complete. Such a lock will protect against delete/add.
But since this is expensive - i.e it will also stop traffic from running
and will require some protection; it is by design therefore not
implemented.

In my opinion:
In your solution, the dump state MUST reflect whats in the kernel not
what was in the kernel when the dump started.

Dont mean to discourage you - perhaps you can come up with some more
clever ideas now that i explained this. I dont know what the best
solution is; however, what you are doing is insuficient in my opinion.

cheers,
jamal

On Tue, 2005-04-12 at 08:31, itkes@imec.msu.ru wrote:
> Hello.
> 
> I think, I have found a bug in the Linux Kernel. It is caused by working
> with lists by indexes in such operstions as routing tables dump and
> routing rules dump (functions fib_rules_dump in fib_rules.c and a few dump
> functions in fib_hash.c). If some elements are removed form the list, the
> index may identify not the element it identified earlier. As a result,
> there may happen that an application that requested the routes or rules
> dump, will not receive the entire table. There is how
> to make an application to lose some rules.
> 
> 1. Add 150 rules to kernel table.
> 2. Application A sends an RTM_GETRULE message with flag NLM_F_DUMP. The
> kernel puts first 107 rules to the buffer.
> 3. Application B deletes first 20 rules.
> 4. Application A receives the first couple of data from kernel. The kernel
> puts next couple of rules to the buffer, begining from 108-th rule, that
> was 128-th earlier.
> As a result, 20 rules had not been sent to the application, without being
> deleted or modified during the dump operation.
> 
> Routes can be lost, too, if you add certain 5000 routes, request their
> dump and remove 1000 from them during the dump.
> 
> In the patch (against kernel 2.6.11) attached, I have corrected these
> bugs. In the modified kernel, both dumps of routes and routing rules seems
> to work properly. But, I think, there can be other bugs similar to this in
> other dump operations.
> 
> Alex Itkes (Moscow State University).
> 
> P.S. I am awfully sorry if you got this message more then once. There were
> some problems with my mailbox so my previous message or your answer might
> be lost.
