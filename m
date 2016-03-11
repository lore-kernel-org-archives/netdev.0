From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Fri, 11 Mar 2016 21:58:54 +0100
Message-ID: <20160311205854.GB1548@breakpoint.cc>
References: <20160310215959.GE1989@uranus.lan>
 <20160310.173630.525547775491939864.davem@davemloft.net>
 <20160310224056.GF1989@uranus.lan>
 <20160311.154046.890043899835986091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gorcunov@gmail.com, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160311.154046.890043899835986091.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Cyrill Gorcunov <gorcunov@gmail.com>
> Date: Fri, 11 Mar 2016 01:40:56 +0300
> 
> > On Thu, Mar 10, 2016 at 05:36:30PM -0500, David Miller wrote:
> >> > 
> >> > Works like a charm! So David, what are the next steps then?
> >> > Mind to gather all your patches into one (maybe)?
> >> 
> >> I'll re-review all of the changes tomorrow and also look into ipv6
> >> masq, to see if it needs the same treatment, as well.
> >> 
> >> Thanks for all of your help and testing so far.
> > 
> > Thanks a lot, David!
> 
> Cyrill please retest this final patch and let me know if it still works
> properly.
> 
> I looked at ipv6, and it's more complicated.  The problem is that ipv6
> doesn't mark the inet6dev object as dead in the NETDEV_DOWN case, in
> fact it keeps the object around.  It only releases it and marks it
> dead in the NETDEV_UNREGISTER case.
> 
> We pay a very large price for having allowed the behavior of ipv6 and
> ipv4 to diverge so greatly in these areas :-(
> 
> Nevertheless we should try to fix it somehow, maybe we can detect the
> situation in another way for the ipv6 side.

Note that as the ipv6 inet notifier is atomic; now that
nf_ct_iterate_cleanup can schedule the ipv6 masq version defers the
cleanup to a work queue, with a backlog cap of 16.  So in case
of a gazillion events most will be ignored and teardown should not be
delayed (at least not even close to what ipv4 masq did).
