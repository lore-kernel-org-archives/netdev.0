From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] decnet: incorrect optlen size
Date: Thu, 29 Jan 2009 17:15:24 -0800 (PST)
Message-ID: <20090129.171524.41361209.davem@davemloft.net>
References: <498166FB.5030104@gmail.com>
	<20090129085858.GA14198@fogou.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, christine.caulfield@googlemail.com,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750701AbZA3BP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:15:26 -0500
In-Reply-To: <20090129085858.GA14198@fogou.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: steve@chygwyn.com
Date: Thu, 29 Jan 2009 08:58:58 +0000

> On Thu, Jan 29, 2009 at 09:21:15AM +0100, Roel Kluin wrote:
> > @@ -1359,10 +1359,10 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
> >  	if (optlen && !optval)
> >  		return -EINVAL;
> >  
> > -	if (optlen > sizeof(u))
> > +	if (optlen < sizeof(u))
> >  		return -EINVAL;
> >
> I don't see that this makes sense... we want to ensure that the passed
> length is less than the size of the union which we are going to use
> as a buffer.
>   
> > -	if (copy_from_user(&u, optval, optlen))
> > +	if (copy_from_user(&u, optval, sizeof(u)))
> >  		return -EFAULT;
> >
>  ... and here we only want to copy the amount of data that has actually
> been supplied, not the whole buffer size since in many cases the
> amount of data is less than the total buffer size.

This code is fine as-is, every single case statement below
this code makes an explicit optlen equality check before
deferencing any member of the union object we copy into.

I'm therefore dropping this patch.
