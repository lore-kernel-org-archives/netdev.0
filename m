From: jamal <hadi@cyberus.ca>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 07:23:49 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
References: <20020729131239.A5183@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rusty Russell <rusty@rustcorp.com.au>,
   <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>,
   <netfilter-core@lists.netfilter.org>
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20020729131239.A5183@wotan.suse.de>
List-Id: netdev.vger.kernel.org



On Mon, 29 Jul 2002, Andi Kleen wrote:

> One obvious problem that it has is that it uses vmalloc to allocate its
> big hash table. This will likely lead to TLB thrashing on a busy box. It should
> try to allocate the hashtable with get_free_pages() first and only fall
> back to vmalloc if that fails. This way it would run with large pages.
>
> (case in point: we have at least one report that routing
> performance breaks down with ip_conntrack when memory size is increased over
> 1GB on P3s. The hash table size depends on the memory size. The problem does
> not occur on P4s. P4s have larger TLBs than P3s.)
>

They also have a lot of problems with their per-packet computations.
Robert and I spent a short time looking at "this thing that is making
us look bad" (perfomance wise) and talked to Harald.
Something that looked like needs improvement at first glance was the aging
and hashing schemes.

cheers,
jamal
