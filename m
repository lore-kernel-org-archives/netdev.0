From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 19 Sep 2004 21:51:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095645106.1048.190.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040918203319.24004d6e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-09-18 at 23:33, David S. Miller wrote:
[..]
> So this patch below attempts to do two things:
> 
> 1) Split fib_node to fib_node and fib_alias.
> 
>    The fib_node is purely a lookup object keyed
>    on destination address and prefix only.
>    Any new lookup algorithm we attempt will modify
>    _only_ the code handling fib_node objects.
> 
>    The fib_alias, on the other hand, describes
>    a sub-route of a fib_node that has different
>    TOS and PRIORITY keys.  Each fib_node has
>    a list of fib_alias objects.
> 
> 2) Use linux/list.h list facilities instead of
>    by-hand list implementations.

I havent tested or patched.
the list changes are nice. I wasnt %100 sure about the need to 
separate fib node into those two. It seems to complicate things.
If you want to allow introduction of new algos, then fib_node itself is
gonna have to go as well IMO. Its an artifact or current alg.
I am actually thinking nothing at all stays of fib_hash.c for any new
algorithm. Infact thats the only new piece/file that a new algorithm
should write.

> I would say that the most complicated part of the
> patch below is the insertion handling.  If an
> entry exists matching the insert request, we have
> to check if this is an exclusive add.  If so,
> then we error, else we append/prepend to the alias
> list depending upon what the user asked for.  Finally
> we also have to check if we are doing a replace.

After patching and/or testing i can give you more feedback.

BTW, one thought to improve perfomance is to change the linked list in
each of the buckets away from a linked list. 

cheers,
jamal
