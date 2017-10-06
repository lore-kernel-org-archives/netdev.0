From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: x_tables: avoid stack-out-of-bounds read
 in xt_copy_counters_from_user
Date: Fri, 6 Oct 2017 15:05:12 +0200
Message-ID: <20171006130512.GA10882@salvia>
References: <1507197007.14419.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171005095644.GB27522@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:41935 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdJFNFV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 09:05:21 -0400
Content-Disposition: inline
In-Reply-To: <20171005095644.GB27522@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 05, 2017 at 11:56:44AM +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > syzkaller reports an out of bound read in strlcpy(), triggered
> > by xt_copy_counters_from_user()
> > 
> > Fix this by using memcpy(), then forcing a zero byte at the last position
> > of the destination, as Florian did for the non COMPAT code.
> > 
> > Fixes: d7591f0c41ce ("netfilter: x_tables: introduce and use xt_copy_counters_from_user")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Willem de Bruijn <willemb@google.com>
> > ---
> >  net/netfilter/x_tables.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> > index c83a3b5e1c6c2a91b713b6681a794bd79ab3fa08..d8571f4142080a3c121fc90f0b52d81ee9df6712 100644
> > --- a/net/netfilter/x_tables.c
> > +++ b/net/netfilter/x_tables.c
> > @@ -892,7 +892,7 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
> >  		if (copy_from_user(&compat_tmp, user, sizeof(compat_tmp)) != 0)
> >  			return ERR_PTR(-EFAULT);
> >  
> > -		strlcpy(info->name, compat_tmp.name, sizeof(info->name));
> > +		memcpy(info->name, compat_tmp.name, sizeof(info->name) - 1);
> 
> Argh, right, compat_tmp.name might not be 0 terminated :-/
> 
> Acked-by: Florian Westphal <fw@strlen.de>

Applied to nf, thanks.
