From: David Miller <davem@davemloft.net>
Subject: Re: multicast, interfaces, kernel 3.0+...
Date: Sat, 22 Sep 2012 00:31:33 -0400 (EDT)
Message-ID: <20120922.003133.2272531217856660981.davem@davemloft.net>
References: <505CB607.7080207@msgid.tls.msk.ru>
	<505D3CE0.2050603@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289Ab2IVEbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 00:31:36 -0400
In-Reply-To: <505D3CE0.2050603@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Sat, 22 Sep 2012 08:21:52 +0400

> The IP_ADD_MEMBERSHIP interface is apparently misdefined, because it
> accepts an IP address of an interface, instead of an ifindex, or
> ifname, or something like this, since there's no, obviously, 1:1
> correspondence between ifaces and addresses, an iface can have no
> addresses assotiated with it, or two ifaces can share one IP address
> like in my case.  But the "questionable" part is the "usualness" of
> this setup I have here, with two ifaces having the same IP address.

Can you at least look at the API specification for IP_ADD_MEMBERSHIP
before making such claims?

The IP_ADD_MEMBERSHIP interface allows for the specification of a
specific interface, the structure you pass into IP_ADD_MEMBERSHIP has
an ->imr_ifindex field and this is the first key the call uses
to pick a device.

If you do not specify an explicit ifindex, and leave it at zero which
I bet your application is doing, it picks the first address which has
the specified address.

As you have discovered, just specifying the address can cause unwanted
effects when multiple devices have the same IP address.  Because the
order of network devices in the system is never, and has never, been
guaranteed.

So the selection in this situation is essentially random because
you haven't given the kernel enough information to choose things
the way that you want it to.
