From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] ipv4: igmp: Allow removing groups from a removed
 interface
Date: Mon, 30 Nov 2015 18:06:27 +0100
Message-ID: <20151130170627.GU32356@lunn.ch>
References: <1448482536-26081-1-git-send-email-andrew@lunn.ch>
 <20151130.110148.959343190265894374.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48051 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224AbbK3RG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 12:06:29 -0500
Content-Disposition: inline
In-Reply-To: <20151130.110148.959343190265894374.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 11:01:48AM -0500, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed, 25 Nov 2015 21:15:36 +0100
> 
> > @@ -2126,7 +2126,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
> >  	ASSERT_RTNL();
> >  
> >  	in_dev = ip_mc_find_dev(net, imr);
> > -	if (!in_dev) {
> > +	if (!imr->imr_ifindex && !imr->imr_address.s_addr && !in_dev) {
> >  		ret = -ENODEV;
> >  		goto out;
> >  	}
> 
> Now, ip_mc_dec_group() below can take a NULL pointer dereference.  One example
> is if imr_ifindex is specified and the lookup returns NULL in ip_mc_find_dev().

Agreed. Earlier code had an if (in_dev) before the call to
ip_mc_dec_group(). It got removed along the way and now needs adding
back. A v2 patch will follow soon.
 
> This is so rediculously complicated, just looking at this code breaks something.

Yep. I think part of the problem comes from the code being designed
before interfaces were hot plugable.
