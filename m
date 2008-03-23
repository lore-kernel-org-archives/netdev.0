From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [IPV6]: Event type in addrconf_ifdown is mis-used.
Date: Sun, 23 Mar 2008 03:17:24 -0700 (PDT)
Message-ID: <20080323.031724.208377895.davem@davemloft.net>
References: <1205850925-11736-1-git-send-email-den@openvz.org>
	<20080322.173843.71057686.davem@davemloft.net>
	<1206259996.7528.12.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, kaber@trash.net,
	containers@lists.osdl.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754619AbYCWKRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 06:17:15 -0400
In-Reply-To: <1206259996.7528.12.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Sun, 23 Mar 2008 11:13:16 +0300

> First, this behaviour is broken for a namespace right now in the 2.6.26
> tree. inet6_dev pointer will be NULL for a loopback inside the
> namespace. The case is simple. Just remove all INET6 addresses from a
> loopback device inside a VE. This will call
>   inet6_addr_del
>     addrconf_ifdown(dev, 1);
>        if (dev == init_net.loopback_dev && how == 1)
>                 how = 0;
> the condition will be false and how will not be changed here.

That's a bug.

You can't mark any namespace's loopback device's inet6_dev as NULL
until you know that all routes, devices, and packets referring to such
devices and routes in that namespace are %100 gone and unreferenced.

It is now obviously apparent that there are several severe errors
here.
