From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 4 May 2015 08:56:40 -0700
Message-ID: <20150504155639.GA14367@Alexeis-MBP.westell.com>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net, jhs@mojatatu.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 12:50:45PM +0200, Pablo Neira Ayuso wrote:
> Hi,
> 
> Another round of the patchset to add Netfilter ingress support. This new
> patchset introduces the necessary updates in 2 steps:
> 
> 1) Add minismalistic ingress hook infrastructure that allows to register one
>    client at a time, so you hit -EBUSY in case the hook is in use. Basically,
>    we have a function pointer that is rcu-protected to invoke the corresponding
>    filter framework which has minimal performance impact in the critical ingress
>    path and avoid more pollution in it. This patch also ports the ingress qdisc
>    on top of this.
...
> In summary, this provides the facility to keep both tc and netfilter in place,
> while the user can select what they prefer to filter from ingress.

wow, I have to say I'm impressed. That's the most genius way to
really kill TC.
Patch 1 looks good, patch 2,3,4 are nicely building on top...
until somebody starts asking how patch 5 will look.
In the future netfilter ingress module will be loaded along with
other iptables modules just like conntrack is today and users
who would want to use ingress tc would have to _unload_
netfilter_ingress module, but if it has interesting dependencies
it may mean to unload iptables and the rest.
So at the end the users will have a binary choice either to use
iptables/nft or use tc, because they won't be able to co-exist
because ingress_hook is the only one.
I don't understand this 'tc hate'. Why go out of the way to
make TC more difficult to use ?
Just add _new_ hook for netfilter ingress and both subsystems
can happily co-exist.

