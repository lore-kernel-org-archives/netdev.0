From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Fri, 9 Oct 2015 09:17:10 +0200
Message-ID: <20151009071710.GJ7701@secunet.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
To: Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50997 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932691AbbJIHRO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 03:17:14 -0400
Content-Disposition: inline
In-Reply-To: <m2a8rs7crl.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2015 at 03:54:22PM +0900, Hajime Tazaki wrote:
> 
> Hello David,
> 
> At Mon,  5 Oct 2015 08:32:51 -0600,
> David Ahern wrote:
> 
> > 
> > diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
> > index 30caa289c5db..5cedfda4b241 100644
> > --- a/net/ipv6/xfrm6_policy.c
> > +++ b/net/ipv6/xfrm6_policy.c
> > @@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
> >  
> >  	memset(&fl6, 0, sizeof(fl6));
> >  	fl6.flowi6_oif = oif;
> > +	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
> >  	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
> >  	if (saddr)
> >  		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
> 
> I found that this fix is still not sufficient with the mip6
> (Mobile IPv6) use case.

It does not even fix the vti case. The behaviour of the vti devices is
the same, with and without the patch.
