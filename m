From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 08:19:19 -0400
Message-ID: <1206706759.4429.58.camel@localhost>
References: <47EC399E.90804@sun.com>
	 <20080327.173418.18777696.davem@davemloft.net>
	 <20080328012234.GA20465@gondor.apana.org.au>
	 <20080327.183844.74572930.davem@davemloft.net>
	 <20080328102931.GA23039@gondor.apana.org.au>
	 <20080328105629.GG1011@elte.hu>
	 <20080328110621.GA23342@gondor.apana.org.au>
	 <20080328112928.GA23547@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>, Matheos.Worku@Sun.COM,
	jesse.brandeburg@intel.com, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:9366 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYC1MUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 08:20:00 -0400
Received: by wa-out-1112.google.com with SMTP id v27so278714wah.23
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 05:19:59 -0700 (PDT)
In-Reply-To: <20080328112928.GA23547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-28-03 at 19:29 +0800, Herbert Xu wrote:

> OK, since we don't really have any good ways of balancing softirq
> events with each other, I've taken Dave's suggestion of checking
> the jiffies as is done with NAPI.  I've kept the need_resched to
> minimise the scheduling latency.

i think the need_resched would be effective.

**** heres something that has not yet resolved in my mind (even for the
NAPI case which was inherited from code that has been there forever).
Theres probably a very simple answer ;->
say we have two machines:
one faster and we decide HZ = 1000 meaning 1ms for a jiffy; the other
slower and we make HZ 100 i.e 10ms jiffy.
Logically, shouldnt the slower machine allocate less time running the
loop since it has less resources? in the above case it would spend 10
times more. 

cheers,
jamal

