From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Mon, 22 Jul 2013 07:52:45 -0700
Message-ID: <20130722075245.70310bfa@nehalam.linuxnetplumber.net>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
	<1374342380.1940.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:49474 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab3GVOws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 10:52:48 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so7223471pad.28
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 07:52:48 -0700 (PDT)
In-Reply-To: <1374342380.1940.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Jul 2013 10:46:20 -0700
Joe Perches <joe@perches.com> wrote:

> On Sat, 2013-07-20 at 10:26 -0700, Stephen Hemminger wrote:
> > Rather than relying on the assumption that zero means empty on
> > hash list head, the code should use the initialization macro.
> > Same effect, but follows API and avoids future breakage if hlist
> > implementation changes.
> []
> > --- a/net/ipv4/ip_tunnel.c	2013-07-19 09:12:37.213529343 -0700
> []
> > -	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
> > +	itn->tunnels = kmalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head),
> > +			       GFP_KERNEL);
> >  	if (!itn->tunnels)
> >  		return -ENOMEM;
> > +
> > +	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
> > +		INIT_HLIST_HEAD(&itn->tunnels[i]);
> 
> Hey Stephen.
> 
> Are you doing to do just this one or submit a series?

Hadn't planned on fixing more than one. And would not go outside code
that I actually use.
