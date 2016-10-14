From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Fri, 14 Oct 2016 13:16:38 +0200
Message-ID: <20161014111638.GA13022@breakpoint.cc>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
 <20161010140424.GB21057@breakpoint.cc>
 <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
 <20161013204338.GA32449@breakpoint.cc>
 <f1df137d-7278-f6fb-3237-1bd20afadb48@6wind.com>
 <20161014103726.GA10404@breakpoint.cc>
 <20161014105327.GA8655@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        davem@davemloft.net, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161014105327.GA8655@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> I would prefer not to expose sysctl knobs, if we don't really know
> what good default values are good, then we cannot expect our users to
> know this for us.
> 
> I would go tune this in a way that this resembles to the previous
> behaviour.

I do not see how this is possible without reverting to old per-conntrack
timer scheme.

With per-ct timer userspace gets notified the moment the timer
fires, without it notification comes 'when kernel detects the timeout'
which in worst case, as Nicholas describes, is when gc worker comes
along.

You can run the gc worker every jiffie of course, but thats just
wasting cpu cycles (and you still get a small delay).

I don't see a way to do run-time tuning except faster restarts when
old entries start accumulating.  This is what the code tries to do,
perhaps you have a better idea for the 'next gc run' computation.

