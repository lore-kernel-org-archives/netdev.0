From: Neil Brown <neilb@suse.de>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 09:07:56 +1100
Message-ID: <20100401090756.69bfb57d@notabene.brown>
References: <20100331223637.31f5f6ed@notabene.brown>
	<20100331114936.3549ca90@s6510>
	<20100401072412.032aa8e6@notabene.brown>
	<20100331.141732.225997212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:53367 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756220Ab0CaWIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 18:08:06 -0400
In-Reply-To: <20100331.141732.225997212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Mar 2010 14:17:32 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Neil Brown <neilb@suse.de>
> Date: Thu, 1 Apr 2010 07:24:12 +1100
> 
> >> --- a/net/ipv4/af_inet.c	2010-03-31 11:47:01.952910248 -0700
> >> +++ b/net/ipv4/af_inet.c	2010-03-31 11:48:09.852938406 -0700
> >> @@ -575,7 +575,7 @@ int inet_stream_connect(struct socket *s
> >>  
> >>  	lock_sock(sk);
> >>  
> >> -	if (uaddr->sa_family == AF_UNSPEC) {
> >> +	if (addr_len < sizeof(sa_family_t) || uaddr->sa_family == AF_UNSPEC) {
> >>  		err = sk->sk_prot->disconnect(sk, flags);
> >>  		sock->state = err ? SS_DISCONNECTING : SS_UNCONNECTED;
> >>  		goto out;
> > 
> > Thanks for the reply.
> > 
> > The implication of this patch is that
> >    connect(fd, NULL, 0)
> > is actually a valid way to check if an in-progress connection has completed.
> > 
> > Is that the intention?
> 
> That's not how I read the patch, the result is that connect(fd, NULL...)
> will now disconnect the socket.

Yes, you are right - I read it upside-down.  Sorry.

Thanks,
NeilBrown
