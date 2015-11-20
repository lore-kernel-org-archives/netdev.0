From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHSET v2] netfilter, cgroup: implement xt_cgroup2 match
Date: Fri, 20 Nov 2015 20:56:25 +0100
Message-ID: <20151120195625.GA1124@salvia>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <20151120.135912.1506496112678349111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tj@kernel.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151120.135912.1506496112678349111.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2015 at 01:59:12PM -0500, David Miller wrote:
> From: Tejun Heo <tj@kernel.org>
> Date: Thu, 19 Nov 2015 13:52:44 -0500
> 
> > This is the second take of the xt_cgroup2 patchset.  Changes from the
> > last take are
> > 
> > * Instead of adding sock->sk_cgroup separately, sock->sk_cgrp_data now
> >   carries either (prioidx, classid) pair or cgroup2 pointer.  This
> >   avoids inflating struct sock with yet another cgroup related field.
> >   Unfortunately, this does add some complexity but that's the
> >   trade-off and the complexity is contained in cgroup proper.
> > 
> > * Various small updats as per David and Jan's reviews.
> 
> I like this a lot better, thanks.
> 
> Please address Daniel's feedback on patch #6 and then I'm personally
> fine with this series.
> 
> Pablo, are you ok with me merging this into net-next directly or
> would you rather I take patches 1-6 into net-next and then you can
> merge and then add patch #7 on top?

I'd suggest you get 1-6, then I'll pull this info my tree. Thanks David!

Regarding #7, I have a couple two concerns:

1) cgroup currently doesn't work the way users expect, ie. to perform any
   reasonable firewalling. Since this relies on early demux, only a
   limited number of sockets get access to the cgroup info.

2) We have traditionally rejected match2 and target2 extensions. I
   guess you can accomodate the new cgroup code through the revision
   iptables infrastructure, so we still use the cgroup match.

Let me know, thanks.
