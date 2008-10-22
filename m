From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Wed, 22 Oct 2008 18:04:55 +0200
Message-ID: <48FF4F27.3090604@trash.net>
References: <20081016220905.GA2747@ami.dom.local> <48F88613.1060404@trash.net> <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net> <20081017204543.GB2527@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56046 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbYJVQE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 12:04:58 -0400
In-Reply-To: <20081017204543.GB2527@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Fri, Oct 17, 2008 at 04:12:03PM +0200, Patrick McHardy wrote:
> ...
>> Some general thoughts ...
>>
>> We've never had any systematic checks for useful and non-useful
>> combination of qdiscs, which is causing a lot of these complications.
>> Think of all the multiq work that was required to make it work
>> properly with non-work-conserving qdiscs - while at the same time,
>> using a non-work-conserving qdisc (which require a global view)
>> defeats basically all of the benefits.
>>
>> So it would be really useful to come up with a systematic definition
>> of valid combinations instead of trying handling lots of purely
>> theoretical case that don't make sense. One more example - all the
>> qdiscs implement ->drop(), yet its only needed by CBQ and it doesn't
>> make any sense at all to use lets say HFSC as child of CBQ.
>>
>> About this specific case - yes, it would break compatibility for
>> users using f.i. TBF as child of netem. But if you look at the
>> netem_enqueue() function, it in fact assumes that the inner qdisc
>> is a tfifo, so we'd be breaking an already broken case. We can
>> of course be nice and warn about it for a few releases, but I believe
>> there is some real potential for simplification that makes it
>> worth it.
> 
> I'm not sure this is all right: at least until there is not too much
> problems with some code (like with requeuing).  We probably should try
> before this official ways like feature-removal-schedule.txt, and/or
> maybe some CONFIG_XXX_DEPRECATED things. But I don't persist with this.

Sure. Nobody reads feature-removal-schedule.txt though, so we should
also have a runtime warning :)

> BTW, I'm not sure if I'm expected to redo any patches in this thread.
> (Probably some things like this teql_peek() could be removed with
> ->requeue() killing.)

Just do the changes you think are right, I'm not expecting you to
do anything I suggested :)

