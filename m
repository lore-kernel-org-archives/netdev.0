From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] [RFC] netfilter: nf_conntrack: don't relase a conntrack
 with non-zero refcnt
Date: Thu, 16 Jan 2014 10:23:01 +0100
Message-ID: <20140116092301.GF28205@breakpoint.cc>
References: <1389710201.31367.255.camel@edumazet-glaptop2.roam.corp.google.com>
 <1389720948-7883-1-git-send-email-avagin@openvz.org>
 <20140114185329.GB28205@breakpoint.cc>
 <20140115180844.GA3605@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netfilter@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Vasiliy Averin <vvs@parallels.com>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140115180844.GA3605@paralelels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Vagin <avagin@parallels.com> wrote:
> > I think it would be nice if we could keep it that way.
> > If everything fails we could proably intoduce a 'larval' dummy list
> > similar to the one used by template conntracks?
> 
> I'm not sure, that this is required. Could you elaborate when this can
> be useful?

You can dump the lists via ctnetlink.  Its meant as a debugging aid in
case one suspects refcnt leaks.

Granted, in this situation there should be no leak since we put the newly
allocated entry in the error case.

> Now I see only overhead, because we need to take the nf_conntrack_lock
> lock to add conntrack in a list.

True. I don't have any preference, I guess I'd just do the insertion into the
unconfirmed list when we know we cannot track to keep the "unhashed"
bug trap in the destroy function.

Pablo, any preference?
