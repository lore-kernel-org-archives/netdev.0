From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 18/79] IPVS: Remove useless { } block from
 ip_vs_process_message()
Date: Tue, 25 Jan 2011 15:16:04 +1000
Message-ID: <20110125051603.GC7183@verge.net.au>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
 <1295464519-21763-19-git-send-email-kaber@trash.net>
 <1295466052.1952.29.camel@Joe-Laptop>
 <20110125020959.GB7420@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44427 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919Ab1AYFQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 00:16:05 -0500
Content-Disposition: inline
In-Reply-To: <20110125020959.GB7420@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 25, 2011 at 12:10:00PM +1000, Simon Horman wrote:
> On Wed, Jan 19, 2011 at 11:40:52AM -0800, Joe Perches wrote:
> > On Wed, 2011-01-19 at 20:14 +0100, kaber@trash.net wrote:
> > > From: Simon Horman <horms@verge.net.au>
> > >  net/netfilter/ipvs/ip_vs_sync.c |   24 +++++++++++-------------
> > > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > > @@ -381,20 +381,18 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> > >  			}
> > >  		}
> > >  
> > > -		{
> > > -			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> > > -					      (union nf_inet_addr *)&s->caddr,
> > > -					      s->cport,
> > > -					      (union nf_inet_addr *)&s->vaddr,
> > > -					      s->vport, &param)) {
> > > -				pr_err("ip_vs_conn_fill_param_sync failed");
> > > -				return;
> > > -			}
> > > -			if (!(flags & IP_VS_CONN_F_TEMPLATE))
> > > -				cp = ip_vs_conn_in_get(&param);
> > > -			else
> > > -				cp = ip_vs_ct_in_get(&param);
> > > +		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> > > +					       (union nf_inet_addr *)&s->caddr,
> > > +					       s->cport,
> > > +					       (union nf_inet_addr *)&s->vaddr,
> > > +					       s->vport, &param)) {
> > > +			pr_err("ip_vs_conn_fill_param_sync failed");
> > 
> > The original and this pr_err is missing a \n before close quote.
> 
> Thanks Joe, I'll get this fixed once nf-next-2.6 opens up again.

On closer inspection this line has subsequently been removed.
I also checked and the string passed to all calls to pr_erri()
in that file end in "\n".
