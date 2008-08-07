From: Rick Jones <rick.jones2@hp.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 07 Aug 2008 11:17:55 -0700
Message-ID: <489B3C53.1000202@hp.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>	<200808072009.34891.rdenis@simphalempin.com> <65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:14358 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbYHGSR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 14:17:57 -0400
In-Reply-To: <65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
>>>We are looking at ways to scale TCP listeners.  I think we like is the
>>>ability to listen on a port from multiple threads (sockets bound to
>>>same port,  INADDR_ANY, and no interface binding) , which is what
>>>SO_REUSEPORT would seem to allow.  Has this ever been implemented for
>>>Linux or is there a good reason not to have it?
>>
>>On Linux, SO_REUSEADDR provide most of what SO_REUSEPORT provides on BSD.
>>
>>In any case, there is absolutely no point in creating multiple TCP listeners.
>>Multiple threads can accept() on the same listener - at the same time.
>>
> 
> 
> We've been doing that, but then on wakeup it would seem that we're at
> the mercy of scheduling-- basically which ever threads wakes up first
> will get to process accept queue first.  This seems to bias towards
> threads running on the same CPU as the wakeup is called, and   so this
> method doesn't give us an even distribution of new connections across
> the threads that we'd like.

How would the presence of multiple TCP LISTEN endpoints change that? 
You'd then be at the mercy of whatever "scheduling" there was inside the 
stack.

If you want to balance the threads, perhaps a dispatch thread, or a 
virtual one - each thread knows how many connections it is servicing, 
let them know how many the other threads are servicing, and if a thread 
has N more connections than the other threads have it not go into 
accept() that time around.  Might need some tweaking to handle 
pathological starvation cases like all the other threads are hung I 
suppose but the basic idea is there.

rick jones
> 
> Tom
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

