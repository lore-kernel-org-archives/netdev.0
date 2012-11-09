From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix the bug when propagating Redirect Message
Date: Fri, 9 Nov 2012 09:54:44 +0100
Message-ID: <20121109085444.GF22290@secunet.com>
References: <5086B721.1090905@gmail.com>
 <20121024045410.GF27385@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59057 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab2KIIyy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 03:54:54 -0500
Content-Disposition: inline
In-Reply-To: <20121024045410.GF27385@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 24, 2012 at 06:54:10AM +0200, Steffen Klassert wrote:
> On Tue, Oct 23, 2012 at 11:26:25PM +0800, Duan Jiong wrote:
> > +	while (opt_len) {
> > +		int l;
> > +	
> > +		if (opt_len < sizeof(struct nd_opt_hdr)) {
> > +			return;
> > +		}
> > +		l = nd_opt->nd_opt_len << 3;
> > +		if (opt_len < l || l == 0) {
> > +			return;
> > +		}
> > +		if (nd_opt->nd_opt_type == ND_OPT_REDIRECT_HDR) {
> > +			__skb_pull(skb, ndisc_head_len + opt_offset + 8);
> > +			break;
> > +		}
> > +		opt_len -= l;
> > +		nd_opt = ((void *)nd_opt) + 1;
> > +		opt_offset += 1;
> > +	}
> 
> Instead of the above loop, you could use ndisc_parse_options().
> This does the same what you are doing here and it would make it
> a bit clearer what's going on.
> 

Duan, are you going to update your patches? We really need fixes
for the problems you have discovered.

Thanks!
