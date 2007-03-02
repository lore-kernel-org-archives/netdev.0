From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Fri, 2 Mar 2007 12:45:36 -0800
Message-ID: <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
References: <20070204074143.26312.qmail@science.horizon.com>
	 <20070217131302.GA22732@2ka.mipt.ru>
	 <20070302085246.GA30951@2ka.mipt.ru>
	 <200703021056.24100.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:4794 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965587AbXCBUph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 15:45:37 -0500
Received: by an-out-0708.google.com with SMTP id b33so854768ana
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 12:45:37 -0800 (PST)
In-Reply-To: <200703021056.24100.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/2/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Thank you for this report. (Still avoiding cache misses studies, while they
> obviously are the limiting factor)

1)  The entire point of going to a tree-like structure would be to
allow the leaves to age out of cache (or even forcibly evict them)
when the structure bloats (generally under DDoS attack), on the theory
that most of them are bogus and won't be referenced again.  It's not
about the speed of the data structure -- it's about managing its
impact on the rest of the system.

2)  The other entire point of going to a tree-like structure is that
they're drastically simpler to RCU than hashes, and more generally
they don't involve individual atomic operations (RCU reaping passes,
resizing, etc.) that cause big latency hiccups and evict a bunch of
other stuff from cache.

3)  The third entire point of going to a tree-like structure is to
have a richer set of efficient operations, since you can give them a
second "priority"-type index and have "pluck-highest-priority-item",
three-sided search, and bulk delete operations.  These aren't that
much harder to RCU than the basic modify-existing-node operation.

Now can we give these idiotic micro-benchmarks a rest until Robert's
implementation is tuned and ready for stress-testing?

Cheers,
- Michael
