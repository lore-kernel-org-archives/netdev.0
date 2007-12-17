From: david@lang.hm
Subject: Re: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 04:10:19 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712170359260.4467@asgard>
References: <20071217092401.GC4356@cs.unibo.it> <Pine.LNX.4.64.0712170327410.4467@asgard>
 <20071217104706.GA10966@ripieno.somiere.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Renzo Davoli <renzo@cs.unibo.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ludovico Gardenghi <garden@cs.unibo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-033-126.lax1.dsl.speakeasy.net ([64.81.33.126]:57650
	"EHLO bifrost.lang.hm" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935360AbXLQK7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 05:59:54 -0500
In-Reply-To: <20071217104706.GA10966@ripieno.somiere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007, Ludovico Gardenghi wrote:

> On Mon, Dec 17, 2007 at 03:31:48AM -0800, david@lang.hm wrote:
>
>> wouldn't it be better to just add the ability for multiple writers to send
>> to the same pipe, and then have all of them splice into the output of that
>> pipe? this would give the same data-agnostic communication that you are
>> looking for, and with the minor detail that software would have to filter
>> out messages that they send, would appear to meet all the goals you are
>> looking at, useing existing kernel features that are designed to be very
>> high performance.
>
> Being able to define both filtering policies (think of a virtual
> ethernet layer 2 switch, for instance. We have situations where dozens
> or hundreds of virtual cables are connected to the same switch, it would
> be much, much slower if you had to awake all the user processes for each
> single non-broadcast ethernet frame, and send them useless data) and
> delivery guarantees (lossless vs best-effort delivery) are not minor
> details in our opinion.
>
> We might have added a level2 virtual ethernet switch at kernel
> level, but it seemed to specific. With a minor effort we have split the
> "dumb" bus (IPN) and the ability to process specific structured data
> with specific policies (sub-modules as kvde_switch).

it seems like you are mixing your use cases and arguing reasons for one 
when answering questions about another.

if you are talking network connections between virtual systems, then the 
exiting tap interfaces would seem to do everything you are looking for. 
you can add them to bridges, route between them, filter traffic between 
them (at whatever layer you want with netfilter), use multicast, etc as 
you would any real interface.

if, however, you are talking about non-network communications (your 
example of sending raw video frames across the interface), and want 
multiple processes to receive them, this sounds like exactly the thing 
that splice was designed to do, distribute data to multiple recipiants 
simultaniously and efficiantly.

I think you need to seperate out these two use cases (and any others you 
are advocating this for) and argue each one on it's own.

> We surely may adapt existing features (AF_UNIX, or pipes) but they offer
> a quite established interface and semantics and we think it should be
> better to add a new family. This would prevent from breaking what
> already exists and leaving more freedom in defining the new family
> according to needs.

for a new family to be valuble, you need to show what it does that isn't 
available in existing families.

> As for ptrace vs utrace: ptrace has been designed for debugging; trying
> to bend it to be fit for virtualization is likely to end up in an
> intricated interface and implementation. utrace has been designed in a
> much more general way. You can implement ptrace over utrace, but you can
> use utrace also for virtualization in a cleaner, simpler and more
> efficient way. Why not?

I'm not familiar enough with ptrace vs utrace to know this argument. but I 
haven't heard any of the virtualization people complaining about the 
existing interfaces. They seem to have been happily useing them for a 
number of years.

David Lang
