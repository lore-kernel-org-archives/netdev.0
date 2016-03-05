From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 20:00:57 +0300
Message-ID: <20160305170057.GN4184@uranus.lan>
References: <1457136510.2761.8.camel@edumazet-ThinkPad-T530>
 <20160304.231109.1838919633640757059.davem@davemloft.net>
 <20160305155714.GM4184@uranus.lan>
 <20160305.113312.1758700509401944239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:35069 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbcCERBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 12:01:22 -0500
Received: by mail-lb0-f173.google.com with SMTP id bc4so91761635lbc.2
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2016 09:01:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160305.113312.1758700509401944239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2016 at 11:33:12AM -0500, David Miller wrote:
> > and until everything get cleaned up I couldn't connect
> > to the node via ssh. I continue playing with patch maybe
> > I find some other optimization paths. Thanks!
> 
> What is the order of magnitude of the delay, as a function of
> number of IP aliases installed, compred to before the patch?

You know I didn't measured precise numbers. The script (which
I of course forgot to attach in first report) creates 65025
addresses and on exit it takes ~10 minutes (it also depends
on load on the host because I've been testing inside VM).

I'll create some kind of graph for that if you interested,
should I?

> The remaining cost you are seeing comes of course from the router
> deletion, whose path is:
> 
> 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
> 		fib_inetaddr_event()
> 			fib_del_ifaddr(ifa, NULL);
> 
> Which does another full list scan trying to handle primaries and
> secondaries.
> 
> Probably the same optimization can be applied there, see patch below.
> And if that doesn't do it, there is a really easy way to batch the
> delete by scanning the FIB tree in one go and deleting every entry
> that points to "in_dev".  But I suspect we really won't need that.

I'll test it David, in a couple of hours I hope. And report the
result.

	Cyrill
