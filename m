From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Mon, 15 Jun 2015 19:26:13 -0500
Message-ID: <87twu8lcre.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<20150615.171042.1771913051598016582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	stephen@networkplumber.org, jjciarla@raiz.uncu.edu.ar,
	wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	jhs@mojatatu.com, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150615.171042.1771913051598016582.davem@davemloft.net> (David
	Miller's message of "Mon, 15 Jun 2015 17:10:42 -0700 (PDT)")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 14 Jun 2015 22:07:30 -0500
>
>> While looking into what it would take to route packets out to network
>> devices in other network namespaces I started looking at the netfilter
>> hooks, and there is a lot of nasty code to figure out which network
>> namespace to filter the packets in.
>
> I am assume that you and Pablo are going to look at eachother's
> work and decide how to proceed and therefore I'm getting another
> series to actually apply at some point in the future.

I am busily looking, and being slightly challenged by the fact that the
netfilter code is a moving target in net-next.  That is not really a
bad thing as some of Pablo's patches were against the patches that
were merged today.

It does look like Pablo's path to getting per network namespace
netfilter hooks is the best path to a good long term result, for per
network namespace hooks.  I am busily agumenting it with a Kconfig guard
so bisection that disables network namespaces support while netfilter
only works on the initial network namespace.  As otherwise bisection
will be a lost cause.  AKA

	config NET_NS
		depends on !NETFILTER

At the same time it looks like Pablos patches come out cleaner when
rebased on my patchset.

The number of conflicts between the two patchsets is very small
and easily resolved.

So what I am in the processes of doing is reviewing and testing
the combined set of patches and hopefully I will have something
for you soon (tomorrow?).  Unless Pablo has objections.

Right now I am attempting to verify that I have found all of the places
in Pablo's patchset where the patches do not compile on their own, as
there were some silly left-overs.

But overall I think Pablo's patches look good.

Eric
