From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next v2 2/3] netfilter: call nf_hook_state_init with
 rcu_read_lock held
Date: Thu, 14 Jul 2016 19:42:13 +0200
Message-ID: <20160714174213.GB27719@breakpoint.cc>
References: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
 <1468337541-23930-3-git-send-email-aconole@bytheb.org>
 <20160714171920.GA1274@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Conole <aconole@bytheb.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160714171920.GA1274@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
> > index 20396499..2e7c4f9 100644
> > --- a/net/bridge/netfilter/ebt_redirect.c
> > +++ b/net/bridge/netfilter/ebt_redirect.c
> > @@ -24,7 +24,7 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
> >  		return EBT_DROP;
> >  
> >  	if (par->hooknum != NF_BR_BROUTING)
> > -		/* rcu_read_lock()ed by nf_hook_slow */
> > +		/* rcu_read_lock()ed by nf_hook_thresh */
> 
> Why are all these comments being renamed in this patch? This patch
> description doesn't say anything about this.

Aaron, I'm sorry about this.

I suggest to do this renaming in a different patch, i.e.
keep the rcu_read_lock in nf_hook_slow in this patch.

