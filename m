From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Mon, 30 Jun 2003 11:54:41 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F008771.5030206@us.ibm.com>
References: <20030626.230727.35666164.davem@redhat.com>	<3EFC668F.9010004@us.ibm.com>	<20030627.144752.78715628.davem@redhat.com> <20030628.130602.63704890.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "YOSHIFUJI Hideaki" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030628.130602.63704890.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org


> 1. is it okay to have another hook for garbbig prefix list?
>    Userspace application can get such information via
>    - routing table
>    - interface flag
> 
> 2. is the "managed" flags etc, which is per interface variable, 
>    really NEWROUTE information?
>    It is NOT L2 thing, but it is per-link information.
>    I think it is NEWLINK thing.
> 
> What I'm thinking is:
> 
>  - fix "ADDRCONF" flag in route information
>  - manage / other flags via NEWLINK message
> (- No new interface to get prefix itself.)


Well, there are two reason that I can see to not do so (ADDRCONF flag is already
fixed in earlier patch) :

-  With the latest submission, the actual code to get the prefix list itself
    is very small, the top level inet6_dump_fib uses either the dump_node or
    the dump_prefix, the latter being the new function added. This is the whole
    user interface, 50 odd lines of code with comments.
-  If I understood your point about using interface flag and routing table,
    you are suggesting that the user can make look at rttable and get the prefix
    entries by make checks (it is non-trivial, eg the address should not LL or MC,
    there should be no nexthop and it should be added via an RA, etc). However,
    having a user interface makes it easier to get the prefix list without
    significant bloat to the kernel, and the user doesn't have to make a lot of
    checks to get the system prefixes. I don't see much gain from this approach.

About your point about the managed flag, I think it is a per interface flag
that gets returned when a request for getting flags on that interface is made.
That's why I have made it per interface as part of a GETLNKFLAGS operation.
I don't understand why you think it is NEWLINK thing (not sure what you mean by
that), since it is a flag information on your existing device that a RA is
advertising. I want to get this information not on receipt of an RA, but when
a request is made.

Thanks,

- KK

