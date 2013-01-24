From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] ip6mr: limit IPv6 MRT_TABLE identifiers
Date: Thu, 24 Jan 2013 12:01:01 +0300
Message-ID: <20130124090101.GC4584@mwanda>
References: <20130124063834.GA5611@elgon.mountain>
 <5100EF60.1080409@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25591 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3AXJBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 04:01:51 -0500
Content-Disposition: inline
In-Reply-To: <5100EF60.1080409@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 09:22:56AM +0100, walter harms wrote:
> 
> 
> Am 24.01.2013 07:38, schrieb Dan Carpenter:
> > We did this for IPv4 in b49d3c1e1c "net: ipmr: limit MRT_TABLE
> > identifiers" but we need to do it for IPv6 as well.  On IPv6 the name
> > is "pim6reg" instead of "pimreg" so there is one less digit allowed.
> > 
> > The strcpy() is in ip6mr_reg_vif().
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
> > index acc3249..351ce98 100644
> > --- a/net/ipv6/ip6mr.c
> > +++ b/net/ipv6/ip6mr.c
> > @@ -1766,6 +1766,9 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
> >  			return -EINVAL;
> >  		if (get_user(v, (u32 __user *)optval))
> >  			return -EFAULT;
> > +		/* "pim6reg%u" should not exceed 16 bytes (IFNAMSIZ) */
> > +		if (v != RT_TABLE_DEFAULT && v >= 100000000)
> > +			return -EINVAL;
> >  		if (sk == mrt->mroute6_sk)
> >  			return -EBUSY;
> >  
> hi Dan,
> that comment left me in a bit confused, i guess you men
>   printf( "pim6reg%u",v) should not exceed IFNAMSIZ (16 bytes) ?

Yes.

> also the if is a bit strange, i assume that RT_TABLE_DEFAULT is const
> so anything else is rejected than v==RT_TABLE_DEFAULT
> (assuming that RT_TABLE_DEFAULT >= 100000000 ....)

I don't understand what you are saying.

The patch is basically copy and pasted from b49d3c1e1c "net: ipmr:
limit MRT_TABLE identifiers".  RT6_TABLE_DFLT is allowed to be a
high number because in ip6mr_reg_vif() we do:

        if (mrt->id == RT6_TABLE_DFLT)
                sprintf(name, "pim6reg");
        else
                sprintf(name, "pim6reg%u", mrt->id);

regards,
dan carpenter
