From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 10:01:42 -0700
Message-ID: <4BB622F6.10606@hp.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>	<j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com> <1270193393.1936.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, Tom Herbert <therbert@google.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:32722 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab0DBRBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 13:01:45 -0400
In-Reply-To: <1270193393.1936.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> 
> Your claim of RPS being not good for applications is wrong, our test
> results show an improvement as is. Maybe your applications dont scale,
> because of bad habits, or collidings heuristics, I dont know.

The progression in HP-UX was IPS (10.20) (aka RPS) then TOPS (11.0) (aka RFS). 
We found that IPS was great for single-flow-per-thread-of-execution stuff and 
that TOPS was better for multiple-flow-per-thread-of-execution stuff.  It was 
long enough ago now that I can safely say for one system-level benchmark not 
known to be a "networking" benchmark, and without a massive kernel component, 
TOPS was a 10% win.  Not too shabby.

It wasn't that IPS wasn't good in its context - just that TOPS was even better.

We also preferred the concept of the scheduler giving networking clues as to 
where to process an application's packets rather than networking trying to tell 
the scheduler.  There was some discussion of out of order worries, but we were 
willing to trust to the basic soundness of the scheduler - if it was moving 
threads around willy nilly at a rate able to cause big packet reordering it had 
fundamental problems that would have to be addressed anyway.  And while it may 
be incindiary to point this out :)  I suspect (without concrete data :) that 
bonding mode 0 is a much, Much, MUCH larger source of out-of-order traffic than 
any plausible scheduler thrashing.

happy benchmarking,

rick jones
