From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 10:57:28 -0400
Message-ID: <49BFBA58.30501@hp.com>
References: <20090316233934.GD32111@codeblau.de> <49BF0A5A.2040501@hp.com> <20090317125845.GB9754@codeblau.de> <49BFA9F0.6070702@hp.com> <20090317141432.GA10575@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Felix von Leitner <felix-kernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:28176 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbZCQO5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 10:57:32 -0400
In-Reply-To: <20090317141432.GA10575@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix von Leitner wrote:
>> Sorry, I just don't buy this.  You imply that you don't want the overhead
>> of storing IPv6 addresses, but you still get this with ::ffff:0.0.0.0.
>> In fact, now your overhead is even worse since ever IPv4 address will be
>> stored stored and interpreted as IPv6 128 bit address.
> 
>> If you really care about overhead, run 2 services.  Your IPv6 service
>> will only track real IPv6 addresses and will reduce you total overhead.
> 
> I am worried about the overhead of storing the IPv6 addresses.
> I am not storing them in the IPv4 case.
> 
> But the socket code has been rewritten to use IPv6 addresses only,
> precisely because IPv4-mapped addresses exist.

So, what you want to do is provide IPv4 only service on a fully
configured dual-stacked machine by running an IPv6 enabled application?

Why do you not want to provide IPv6 side of the same service?

You mentioned overhead (and I am guessing that's the answer the above question),
but is the number of IPv6 clients so high that your service would
not be able to handle it.

As I've already mentioned, your overhead of tracking IPv6 clients is actually
lower that tracking all the IPv4 clients using mapped addresses.

One way of preventing the tracking IPv6 clients is by disallowing IPv6 traffic
or even not configuring any IPv6 addresses.  That could get what you want
right now, without waiting for a kernel patch.

> 
>> If you don't care about overhead, just bind a single socket to :: and
>> you will get behavior identical for the ::fff:0.0.0.0 case, but with
>> the added benefit of tracking real ipv6 addresses as well.
> 
> You probably mean well but please stick to the problem at hand and don't
> speculate about my app.
> 
>> Having written support for ::ffff:0.0.0.0, I've always thought it was
>> a bastardized case that didn't provide any benefits.  It was like saying:
>> "I've got IPv6 on my system, but I don't really support it, even though
>> I pretend that I do."
> 
> The app has a command line option to specify which address to bind to.
> The app understands IPv4 addresses and converts them to ipv4 mapped
> addresses so it can only deal with sockaddr_in6 when talking to the
> kernel and does not need to store info on what kind of socket family it
> is dealing with.
> 
> If someone specifies 0.0.0.0, it does not work.  It's that easy.
> 
> Now it may be a fascinating side discussion on whether you think IPv4
> mapped 0.0.0.0 is useful or not, but rest assured: it is useful to at
> least one high profile app that is so far running on Linux.
> 

In this case, you are making a trade-off of application complexity against
kernel complexity.  You are making your application much simpler, while demanding
more complexity from the kernel.

It is your right as an application developer, and it our right as kernel developers
to push back and provide alternatives.

>>> Why would you say that?
>> Because that case doesn't provide any benefits.
> 
> You may not see it but it does.
> 
>> It only has the drawback that you have to deal with ipv4-mapped IPv6
>> addresses witch is the overhead of the whole thing.
> 
> That is not a drawback.  On the contrary.  It greatly simplifies how the
> app deals with the socket API.
> 
>> If you are prepared to deal with it, you might as well deal with real ipv6 addresses
>> at the same time and mitigate your overhead somewhat.
> 
> You are currently proving all the snide remarks by the BSD people about
> the Linux IP stack true, and the "professionalism" snide remarks of the
> Solaris people.  Great work, man.
> 

This is really a great way to convince someone to do the work... :/

-vlad

