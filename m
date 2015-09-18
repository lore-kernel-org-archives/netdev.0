From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH next 0/15] netfilter: Stop guessing net (take 2)
Date: Fri, 18 Sep 2015 22:21:19 +0200
Message-ID: <20150918202119.GA31424@salvia>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
 <87pp1fpy1b.fsf@x220.int.ebiederm.org>
 <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 18, 2015 at 02:28:40PM -0500, Eric W. Biederman wrote:
> 
> This is the next installment of my work to pass struct net through the
> output path so the code does not need to guess how to figure out which
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
> 
> This round the changes focus on using nf_hook_state->net in the
> netfilter functions, and not passing nf_hook_ops to the functions on the
> netfilter chains.
> 
> Given the way per network namespace operations are implemented callers
> can not rely on addresses or games with container_of.  None of the
> netfilter hooks do but we should remove the temptation.  Plus removing
> the extra parameter and the extra jump to get at values should reduce
> the number of cache line misses.
> 
> At a practical matter this is the bulk of the work that other pieces of
> code in the netfilter stack will depend on.
> 
> Since the last round I have fixed my test config to build act_connmark
> and added the patch that modifies act_connmark to track which network
> namespace it was it.

I'm going to place this series in the nf-next tree, thanks! If there's
some fallout, please send me an incremental fix.

> The changes are also available against net-next at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master
> 
> My entire pending set of changes for those who want to look ahead is at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git for-testing

I can see quite a lot of changes for IPVS. I'd suggest you route IPVS
changes through ipvs-devel mailing list so Simon picks them from
there.

Will be preparing a batch with Netfilter updates for net-next to pass
up to David asap.
