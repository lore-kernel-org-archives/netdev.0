From: Joe Nall <joe@nall.com>
Subject: Re: [PATCH] xfrm: export xfrm garbage collector thresholds via sysctl
Date: Mon, 27 Jul 2009 15:02:20 -0500
Message-ID: <7E46FEB5-E422-45B2-9D68-010DD7C23B78@nall.com>
References: <20090727182246.GC15823@hmsreliant.think-freely.org> <20090727.113755.260927092.davem@davemloft.net> <20090727193625.GD15823@hmsreliant.think-freely.org> <20090727.124011.05728493.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:51188 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753648AbZG0UC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 16:02:28 -0400
In-Reply-To: <20090727.124011.05728493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jul 27, 2009, at 2:40 PM, David Miller wrote:

> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 27 Jul 2009 15:36:25 -0400
>
>> I think that makes sense, since it means we only keep cache entries
>> for active connections, and clean them up as soon as they close
>> (e.g. I don't really see the advantage to unhashing a xfrm cache
>> entry only to recreate it on the next packet sent).
>
> How is this related to the user's problem?
>
> My impression was that they were forwarding IPSEC traffic when
> running up against these limits, and that has no socket based
> assosciation at all.
>
> Making the XFRM GC limits get computed similarly to how the
> ipv4/ipv6 one's do probably makes sense.

The problem was seen serving TCP connections over IPSec when the  
server (a 24 core machine w 32GB RAM) and the IPSec host were the same  
(transport not tunnel).

The problem was originally identified in an MLS ipsec thin client  
stress test with 25 clients and 200+ windows per client.

We then duplicated the issue with single level xclocks on the same  
hardware.

I then duplicated the problem with two bone stock (not MLS) F10 (and  
later F11) boxes running ab (apache benchmark tool) with 10k requests  
over 2k concurrent connections. See https://bugzilla.redhat.com/show_bug.cgi?id=503124

With the gc_thresh raised to 8k, my ab test passes with 5k+  
connections and 100k requests. Our test guys ran 11 workstations with  
about 2200 concurrent X connections over the weekend and I'm hoping  
for some MLS results before we lose the test suite on Wednesday.

joe
