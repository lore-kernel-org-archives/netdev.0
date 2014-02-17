From: David Miller <davem@davemloft.net>
Subject: Re: Getting a NIC's MTU size
Date: Mon, 17 Feb 2014 00:21:53 -0500 (EST)
Message-ID: <20140217.002153.1121569813590047048.davem@davemloft.net>
References: <26474.1392388608@warthog.procyon.org.uk>
	<26769.1392390042@warthog.procyon.org.uk>
	<27696.1392392957@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaBQFVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:21:55 -0500
In-Reply-To: <27696.1392392957@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Howells <dhowells@redhat.com>
Date: Fri, 14 Feb 2014 15:49:17 +0000

> One further question:  If I want to get the MTU size of the NIC through which
> packets will go to get to a particular peer, can I do:

As has been suggested or at least hinted to by others, you have to use
the route dst's device pointer.

Practically speaking, this means you'll have to cache the route, just
like we do in ipv4 sockets.  And on each packet send 1) validate the
route and relookup if it's become obsolute 2) dereference the dst->dev
to get the mtu.

This is because routes can change dynamically as can the physical
device's MTU setting, you'll therefore have to evaluate everything
on every packet send.
