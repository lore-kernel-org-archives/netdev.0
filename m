From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipvs-next] ipvs: Remove
 rcu_read_unlock();rcu_read_lock();
Date: Thu, 25 Apr 2013 07:04:03 -0700
Message-ID: <1366898643.8964.139.camel@edumazet-glaptop>
References: <1366852353-32561-1-git-send-email-horms@verge.net.au>
	 <alpine.LFD.2.00.1304251038541.1752@ja.ssi.bg>
	 <1366880726.2628.177.camel@hawk.mlab.se>
	 <20130425133639.GC10898@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130425133639.GC10898@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-25 at 22:36 +0900, Simon Horman wrote:

> Ok, leaving it seems reasonable.
> Pablo, do you have any objections?

I have objections.

I would _add_ a cond_resched() there to explicitly do what we want

Maybe a macro/inline doing this already exists.

static void inline cond_resched_rcu_lock(void)
{
	if (need_resched()) {
		rcu_read_unlock();
		cond_resched();
		rcu_read_lock();
	}
}





