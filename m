From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 02 Aug 2006 10:58:49 +0300
Message-ID: <44D05B39.5080608@tcs.hut.fi>
References: <44CB2914.9010803@linux-ipv6.org> <20060729141244.GJ8334@innerghost.net> <20060801.173535.38709014.davem@davemloft.net> <20060802005849.GK8334@innerghost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGU=?=
	 =?UTF-8?B?YWtpIC8g5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:20232 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1750843AbWHBH6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 03:58:51 -0400
To: Hugo Santos <hsantos@av.it.pt>
In-Reply-To: <20060802005849.GK8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hugo Santos wrote:
> David,
> 
> On Tue, Aug 01, 2006 at 05:35:35PM -0700, David Miller wrote:
>> This is partly why the multiple routing table code is being
>> added as the initial infrastrucutre, so that source based
>> things are possible.
> 
>    There have been other approaches for partial source-based stuff. For
>  instance, in my tree i brought Subtrees back to a point of being
>  usable. But what i was refering to was route-caching (some places only
>  check cookies based on dst because we "don't support source routing"),
>  APIs, etc. A few mails back you pointed the extension of a public
>  structure to include a "source" attribute -- this is the kind of stuff
>  we must add and that i think it's an independent work (read: even if
>  the rest isn't merged, this should).
> 
>    Still regarding Subtrees, is there any interest in revitalizing that
>  code? I have a couple patches that i could submit.

Hi Hugo,

I don't want to be dismissive towards your patches, but I've been
working with the subtree routing stuff for several years now. And let me
tell you: it has provided us with some nasty little surprises every now
and then. I'm only saying it's surprisingly difficult to get right on
the first try.

To name just one issue: the chicken and egg problem of source address
selection and source address based routing. I solved this problem by
letting policy rules (with a source prefix) add additional constraints
to the address selection. This did however mean the source address
selection had to be moved inside the routing code.

This is just one example; trust me, there are several more.

My latest incarnation of source address routing is against my previous
version of policy routing, which luckily isn't that different from
current the version by Thomas. Unless Yoshifuji-san has already ported
my code to Thomas'es policy routing code, I'll start working on it.

>> Such a scheme would need provisions for handling the case where
>> the user eats the message, but never tells us what to do.
>> In such a case we'd need to emit some kind of ICMPv6 message,
>> even if it would be just a timeout generated parameter problem.
> 
>    As i see it, the moment there is a raw socket open for dealing with a
>  particular protocol, whoever opened that socket (handling the protocol)
>  is responsible of generating any error messages associated with the
>  protocol running.  Which is the case, the kernel shouldn't need to know
>  whether any of the Mobile IPv6 specific messages have problems. The
>  particular patch i was refering to does partial MIPv6 message
>  processing inside the kernel before handing it to the socket as you
>  only have access to the full received headers there.
> 
>> Such a layer would be needed if we ever put some kernel level
>> components of Mobile IPv4 into the tree, which I see no reason
>> not to, since it has this route optimization as well.
> 
>    Yes, the functionality is needed. My only problem is with exposing
>  MODE_ROUTEOPTIMIZATION, it isn't modular. But it's something i can live
>  with.

But route optimization is just one form of packet transform; it just
adds a Routing Header type 2 and/or Home Address Option Destination
Header to the outgoing packet. Isn't xfrm just the right place for this?

You are right that we (HUT and USAGI) have mostly just looked at the
xfrm framework from a MIPv6+IPsec perspective, but even this has helped
us pinpoint several shortcomings in the current only IPsec specific
framework.

IMO, this doesn't hinder, but rather helps change xfrm into the generic
packet transform framework it was originally envisioned to be.

Regards,
Ville
