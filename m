From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 17:20:15 -0500
Message-ID: <1259446815.3864.97.camel@bigi>
References: <1259429774.3864.41.camel@bigi>
	 <20091128190500.GB12264@sch.bme.hu> <1259437442.3864.61.camel@bigi>
	 <20091128.132158.34557470.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, hidden@balabit.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:32942 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578AbZK1WUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 17:20:11 -0500
Received: by qw-out-2122.google.com with SMTP id 3so477751qwe.37
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 14:20:17 -0800 (PST)
In-Reply-To: <20091128.132158.34557470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 13:21 -0800, David Miller wrote:

> What matters is that this worked for years and we broke it.

But Tproxy just went in.

> There is no other valid discussion about this.

Surely we can have a valid technical discussion, no? 
I would like to hear from Krisztian his reasoning for using LOCAL
routes. There may be good reasons.

> The only thing to "pick" right now is whether we revert the
> thing completely or add a sysctl and default it to off.
>
> I prefer the former because nobody is going to turn the thing
> on, especially not distributions, and that's %99.9999 of users.

There is nothing to sysctl control. 
IMO, what is at stake here is the check:

-----
        if (res.type != RTN_UNICAST)
                goto e_inval_res;
----

There are several ways to resolve that:
a) either we say RTN_LOCAL is also legit if some
skb->transparent is set. IMO it is not worth it.
b) have the routing table (as programmed by the user) return 
RTN_UNICAST
c)do the approach Krisztian talked about - which is also
user space controlled.

cheers,
jamal

