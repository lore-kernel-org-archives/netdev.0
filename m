From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Tue, 08 Sep 2009 17:43:43 +0200
Message-ID: <1252424623.5827.14.camel@fnki-nb00130>
References: <4AA1C0FF.4030109@hp.com> <1252418247.5827.8.camel@fnki-nb00130>
	 <4AA675D4.8030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: david Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:60016 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbZIHPnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 11:43:50 -0400
In-Reply-To: <4AA675D4.8030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-08 at 11:18 -0400, Brian Haley wrote:
> Jens Rosenboom wrote:
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -1376,7 +1376,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
> >>  	if (ifp->flags&IFA_F_PERMANENT) {
> >>  		spin_lock_bh(&ifp->lock);
> >>  		addrconf_del_timer(ifp);
> >> -		ifp->flags |= IFA_F_TENTATIVE;
> >> +		ifp->flags |= IFA_F_DADFAILED;
> > 
> > I think you still have to set IFA_F_TENTATIVE here, too, otherwise
> > ipv6_dev_get_saddr() will use this address. 		
> 
> The tentative bit is still set from when this address was added back
> in ipv6_add_addr() from what I can tell, re-setting it here is actually
> unnecessary.  At least /sbin/ip was still showing it set during my
> testing.

There is the possibility of a race when the dad_timer expires at the
same time the NA triggering DAD failure is received. There isn't a big
chance to see that during real world testing, though.

