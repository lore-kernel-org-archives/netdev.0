From: kuznet@ms2.inr.ac.ru
Subject: Re: Question about netlink
Date: Wed, 9 Jul 2003 03:50:54 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307082350.DAA13835@dub.inr.ac.ru>
References: <3F0B294A.9060302@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com (Krishna Kumar)
In-Reply-To: <3F0B294A.9060302@us.ibm.com> from "Krishna Kumar" at Jul 08, 2003 01:27:54 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> These routines 'get' the value of args[0] and then 'set' it to the resultant value. How is
> this value set in the first place to the user provided value ?

It is not. Zero values means that dump starts from the very beginning.
It is supposed to be done at the first entry to the ->dump(),
but selective dumps are not implemented in the most of ->dump() methods.


> missing something or is 'args' not intended for user specified arguments ? If so, how
> should we access the arguments passed by the user ?

The pointer to nlmsg header is kept in cb->nlh. So, you can refer to
it to get user supplied values of selector to rewind the dump to required
point at the first entry or to select some specific entries while scanning
a table.

F.e. look into sch_api.c:tc_dump_tclass(), it scopes dump to a netdevice
(tcp_ifindex), and filters answers to a specific qdisc (tcp_parent).
It is also partial. More finegrain selection is not required, but desired,
feel free to implement. F.e. implementation of "ip route ls root 3ffe::/24",
which translates to selection of a root node for fib6_walk() to a more
specific place and filtering out some nodes while walking, would be cool.

Alexey
