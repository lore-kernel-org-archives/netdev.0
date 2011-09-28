From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC v2 0/5] netfilter reverse path filter matches
Date: Wed, 28 Sep 2011 23:18:47 +0200
Message-ID: <20110928211847.GC2761@1984>
References: <1315856552-1422-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1315856552-1422-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2011 at 09:42:27PM +0200, Florian Westphal wrote:
> Version 2 of the ipv4/v6 reverse path filter matches discussed during
> nfws 2011.
> 
> The ipv4 match (ipt_rpfilter) tries to do exactly what the current
> fib_validate_source does.  The main problem with this is that
> we need to do an additional fib lookup to get the oif in the match.
> [ delaying until FORWARD is invoked is not possible because by
>   that point the stack might have already sent icmp errors ].
> 
> Patrick McHardy suggested to simply attach the result as the dst, so
> ipv4 input path doesn't have to do it again.
> 
> This works, but does have a few side effects wrt. route-by-mark and
> TPROXY, see patch changelog for details.
> 
> The ipv6 version does a pure 'reverse' lookup instead.  This makes
> things a lot easier (e.g. when multiple route entries exist), but has
> the caveat that a real reply packet might be handled differently due to
> policy routing rules.
> 
> Userspace part is stored in my iptables repository on
> http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/iptables.git (branch 'rpfilter').
> 
> Kernel patches are located in the 'xt_rpfilter_5' branch on
> http://git.breakpoint.cc/cgi-bin/gitweb.cgi?p=fw/nf-next.git
> (patches will be sent as followup to this email).
> 
> [ in case you are wondering: the earlier xt_rpfilter version was
>   removed -- causes too many module  dependency issues and most of the
>   code cannot be shared anyway ].

This involves other net changes, I'd like to get an ack from David
before applying this. Or let me know if it's better to follow the
netdev path.
