From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Thu, 02 Apr 2015 12:24:40 -0400 (EDT)
Message-ID: <20150402.122440.1290555618096731307.davem@davemloft.net>
References: <1427936176.1899545.248339037.14F4C167@webmail.messagingengine.com>
	<1427939630.25985.186.camel@edumazet-glaptop2.roam.corp.google.com>
	<1427974448.2093675.248500389.6D8AFBB6@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, cwang@twopensource.com,
	netdev@vger.kernel.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbDBQYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 12:24:43 -0400
In-Reply-To: <1427974448.2093675.248500389.6D8AFBB6@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 02 Apr 2015 13:34:08 +0200

> My plan is that I actually would propose this patch for -net and stable
> as it fixes the problem that currently we oops when running dhclient on
> a vxlan interface. As soon as net gets merged into net-next I I would
> propose this change if it works out smoothly and looks maintainable.

Yes, I think this patch is good for -net and -stable, but longer term we
have to do something better.

The most infuriating thing about this mess is that passing the tunnel
socket down is only difficult because of that damn okfn argument to
nf_hook().

And that is _only_ needed for nf_queue reinjection, absolutely nothing
else in the world uses it.

I can't believe how much of a price we pay for that feature :-/

So I've been trying to brainstorm a way to get rid of the okfn argument,
or somehow make adjustments to it's signature more painless.
