From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 5/9] netfilter: conntrack: small refactoring of
 conntrack seq_printf
Date: Wed, 4 May 2016 00:27:36 +0200
Message-ID: <20160503222736.GK2395@breakpoint.cc>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <1461863628-23350-6-git-send-email-fw@strlen.de>
 <20160503181250.GA4508@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160503181250.GA4508@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > -	if (NF_CT_DIRECTION(hash))
> > -		goto release;
> > -	if (nf_ct_l3num(ct) != AF_INET)
> > +	/* check if we raced w. object reuse */
> > +	if (!nf_ct_is_confirmed(ct) ||
> 
> This refactoring includes this new check, is this intentional?

Hmm, yes and no.

I should have put it in an extra commit :-/

Without this, we might erronously print a conntrack that is NEW
and which isn't confirmed yet.

We won't crash since seq_print doesn't depend on extensions being
set up properly, but it seems better to only display those conntracks
that are part of the conntrack hash table (i.e., have the confirmed bit
set).

Let me know if you want me to respin this as a separate fix, thanks!
