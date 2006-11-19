From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix NULL dereference in ipv6_del_addr()
Date: Sun, 19 Nov 2006 17:51:21 -0500 (EST)
Message-ID: <20061119.175121.85391637.davem@davemloft.net>
References: <455DB884.3050203@tcs.hut.fi>
	<20061117.232623.61341274.yoshfuji@linux-ipv6.org>
	<455E0D19.1060405@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:27858 "EHLO localhost")
	by vger.kernel.org with ESMTP id S933604AbWKSWvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 17:51:21 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <455E0D19.1060405@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Fri, 17 Nov 2006 21:27:21 +0200

> YOSHIFUJI Hideaki wrote:
> > In article <455DB884.3050203@tcs.hut.fi> (at Fri, 17 Nov 2006 15:26:28 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> > 
> > 
> >> -		dst_release(&rt->u.dst);
> >> +		if (rt)
> >> +			dst_release(&rt->u.dst);
> >>  	}
> > 
> > I disagree.  This does NOT fix any bugs.
> > 
> > (void *)&rt->u.dst is ever equal to (void*)rt, and
> > dst_release() checks if the argument is NULL.
> 
> As the check is unnecessary you probably want to clean up the other 
> places where rt is checked before &rt->u.dst is passed, as well ;-)
> This is done at least in addrconf.c, ndisc.c and route.c...
> 
> Seriously though, you are probably right about the pointer being equal 
> to NULL in this case,  but does the C language actually guarantee that 
> the pointer to the structure and its first element are equal, or is it 
> implementation dependent? I don't have my K&R here, so I can't check.

I would imagine that it does.  We rely on similar struct layout
semantics in other areas of the networking.

Also, in the past I've been told by GCC folks that the only way to
guarentee that two objects appear together, one after another, in
the .data segment is to place them into a structure :)

I don't think, therefore, that this will ever break.
