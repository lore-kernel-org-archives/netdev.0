From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter
 call_iptables hooks by default
Date: Fri, 19 Sep 2014 12:13:12 +0200
Message-ID: <20140919101312.GA2054@breakpoint.cc>
References: <1410969137-11885-1-git-send-email-fw@strlen.de>
 <20140918133511.GA8740@salvia>
 <20140918143108.GB8484@breakpoint.cc>
 <20140918183956.GA3989@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140918183956.GA3989@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> We can keep those sysctls there in bridge.ko and deprecated them in
> favour of br_netlink. I think we can add some IFLA_BRPORT_NF for the
> setlink command to replace the existing global proc nf-call-thing.
> We'll have to enhance the 'bridge' tool in iproute2 to support this.

Not sure this is needed.  Patrick added support for a per-bridge
sysfs flag a while back.

> > Then, in two years or so, we would remove the autoload hook
> > in the packet procesing path.
> 
> Agreed. By that time, we can kill the bridge.ko <-> br_netfilter.ko
> dependency and the /proc call-nf-bridge stuff in favour of br_netlink.
> 
> Let me know if you still have any concern. Thanks.

Yes, well... I am afraid Patrick is right, we cannot remove it without
breaking some setups.

So, what to do?

I think the first step would be to go ahead and split the hook glue to
a separate module, and then add the autoprobing from the packet processing
path (only loading br_nf module when needed).

We could still add a deprecation warning later on (aka 'please modprobe
br_nf_core' instead).  But yes, Patricks probably right, waiting two
years doesn't make it more 'safe' than waiting 6 months...

What _might_ help is if there was an easy (and fast) way to tell wheter
iptables rules are loaded (right now it checks for active netfilter hooks).

Then, we could restrict the autoload to arp/ip(6)tables and not load
the br_nf glue module when nft is used instead.

That will allow removing autload with iptables removal.  Yes, I know
this is in a very distant future...
