From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 22:45:03 +0200
Message-ID: <20080328203358.M8487@visp.net.lb>
References: <47EBC641.8040405@cosmosbay.com> <20080327183745.M9944@visp.net.lb> <47EBEDC9.6080100@cosmosbay.com> <20080327.150308.205829519.davem@davemloft.net> <20080328052543.M60286@visp.net.lb> <47EC8701.1080604@cosmosbay.com> <20080328073854.M73368@visp.net.lb> <47ECA24C.10803@cosmosbay.com> <47ED1583.5010204@cosmosbay.com> <20080328132359.15573601@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080328132359.15573601@speedy>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems or patch change something (but it is just showing debug, strange), 
or there is something fixed between 2.6.25-rc7-git1 and 2.6.25-rc7-git3. LC-
trie working fine, HASH also i cannot see any leaks.

I  will have to wait 5-6 hours to make sure. After this time pass, if i will 
not see bug again, i will try to run kernel just with default debug like 
before.

If it is required, i can test performance and cpu load with/without routing 
cache on real workload. Sure it is better to have syntetic tests before that.


On Fri, 28 Mar 2008 13:23:59 -0700, Stephen Hemminger wrote
> On Fri, 28 Mar 2008 16:57:55 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > Eric Dumazet a [UTF-8?] :
> > > Denys Fedoryshchenko a [UTF-8?] :
> > >> Already patched and tested, it doesn't change anything.
> > >>
> > >>   
> > >
> > > We still leak dsts somewhere.
> > >
> > > You could try git bisect, or try to patch net/core/dst.c so that 
> > > dst_gc_task() (line 83) displays
> > > route informations for say 10 first entries found in the dst_busy_list
> > > (refcnt, interface, source IP, dest IP, things like that) that could 
> > > ring a bell given your netfilter rules or network conf.
> > 
> > I cooked a patch (untested) to implement this idea :
> > 
> > It should display lines similar to /proc/net/rt_cache (reusing the same 
> > helper function)
> > 
> >
> 
> I wonder how much the route cache really helps when it grows so 
> large? Robert Olsson had suggested that turning it off when routing 
> would help. Perhaps the route cache is only really useful for local 
> destinations? If the cost of maintaining the route cache exceeds the 
> cost of just using the existing route table, there is no value to 
> having a route cache.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

