From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 1/3] [IPV6]: Event type in addrconf_ifdown is mis-used.
Date: Sun, 23 Mar 2008 17:34:59 +0300
Message-ID: <1206282899.7528.18.camel@iris.sw.ru>
References: <1205850925-11736-1-git-send-email-den@openvz.org>
	 <20080322.173843.71057686.davem@davemloft.net>
	 <1206259996.7528.12.camel@iris.sw.ru>
	 <20080323.031724.208377895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net,
	containers@lists.osdl.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7281 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758840AbYCWOgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 10:36:46 -0400
In-Reply-To: <20080323.031724.208377895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-03-23 at 03:17 -0700, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Sun, 23 Mar 2008 11:13:16 +0300
> 
> > First, this behaviour is broken for a namespace right now in the 2.6.26
> > tree. inet6_dev pointer will be NULL for a loopback inside the
> > namespace. The case is simple. Just remove all INET6 addresses from a
> > loopback device inside a VE. This will call
> >   inet6_addr_del
> >     addrconf_ifdown(dev, 1);
> >        if (dev == init_net.loopback_dev && how == 1)
> >                 how = 0;
> > the condition will be false and how will not be changed here.
> 
> That's a bug.
> 
> You can't mark any namespace's loopback device's inet6_dev as NULL
> until you know that all routes, devices, and packets referring to such
> devices and routes in that namespace are %100 gone and unreferenced.
> 
> It is now obviously apparent that there are several severe errors
> here.

You are perfectly correct and the place in addrconf_cleanup is that
place when we believe that we should destroy all the staff.

You see, it is pretty useless to call addrconf_ifdown(dev, 2) after
addrconf_dev(dev, 0) for a loopback in the current code! No new cleanups
will be performed for 2, pls check :)

