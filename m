From: Andi Kleen <ak@suse.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 13:12:39 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729131239.A5183@wotan.suse.de>
References: <20020718093928.18BC942CD@lists.samba.org> <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207290648020.12604-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

> >
> > Connection tracking:
> 
> Fix perfomance problems with this thing. You may have seen reports of
> performance degradation it introduces. I was hoping to take a look at some
> point time hasnt been visiting this side.

One obvious problem that it has is that it uses vmalloc to allocate its
big hash table. This will likely lead to TLB thrashing on a busy box. It should 
try to allocate the hashtable with get_free_pages() first and only fall
back to vmalloc if that fails. This way it would run with large pages.

(case in point: we have at least one report that routing 
performance breaks down with ip_conntrack when memory size is increased over 
1GB on P3s. The hash table size depends on the memory size. The problem does 
not occur on P4s. P4s have larger TLBs than P3s.)

-Andi
