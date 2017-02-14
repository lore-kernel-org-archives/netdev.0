From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: xfrm_neigh_lookup and dst->path
Date: Tue, 14 Feb 2017 08:13:35 +0100
Message-ID: <20170214071335.GI30338@gauss.secunet.com>
References: <alpine.LFD.2.11.1702111354440.1601@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59114 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751550AbdBNHSc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 02:18:32 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1702111354440.1601@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 11, 2017 at 03:12:44PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 3 Feb 2017, Steffen Klassert wrote:
> 
> > On Thu, Feb 02, 2017 at 01:04:34AM +0200, Julian Anastasov wrote:
> > > 
> > > 	For now I installed common handler, just like
> > > xfrm_neigh_lookup. BTW this function has problem from
> > > commit f894cbf847c9, it looks like dst is wrongly provided,
> > > first arg should be dst->path.
> > 
> > Yes, this should use dst->path of course. I really wonder why
> > nobody noticed this for the last five years.
> 
> 	IMHO, xfrm_neigh_lookup is not used often.

I really wonder if it is used at all, given that this bug exists
for more than five years now and nobody reported it so far.

> If used,
> it should be from a place before skb->dst xforms are popped in
> xfrm_output_one, i.e. somewhere before the output processing.
> I see that dst_neigh_lookup*() is used mostly in xmit handlers
> of tunnel devices, I assume, after xfrm_output_one().
> Not sure for br_nf_pre_routing_finish_bridge().
> 
> 	I'm trying to fix this code but we have the
> same problem as in xfrm_confirm_neigh: to find address
> of last tunnel. Should we use the same loop?

Yes, I think this is the right thing to do.

Thanks!
