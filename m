From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 3/3] netfilter: ipv6: add getsockopt to retrieve origdst
Date: Tue, 13 Nov 2012 09:59:30 +0100
Message-ID: <20121113085930.GE20678@breakpoint.cc>
References: <1352765203-4160-1-git-send-email-pablo@netfilter.org>
 <1352765203-4160-4-git-send-email-pablo@netfilter.org>
 <50A1BEA0.8070504@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50A1BEA0.8070504@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> wrote:
> pablo@netfilter.org wrote:
> > From: Florian Westphal <fw@strlen.de>
> > +	sin6.sin6_scope_id = sk->sk_bound_dev_if;
> > +
> > +	nf_ct_put(ct);
> > +	return copy_to_user(user, &sin6, sizeof(sin6)) ? -EFAULT : 0;
> > +}
> > +
> 
> I think we should set sin6_scope_id to sk->sk_bound_dev_if only if the
> destination is link-local address.

Right, I see that getpeer/sockname has this test.

Dave, please either apply the patch as is (I'd submit a fixup)
or discard i, I'll then send a V2 with added
ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL
test to Pablo.

Thanks for reviewing.
