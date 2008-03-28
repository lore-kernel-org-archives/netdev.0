From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 15:12:48 +0100
Message-ID: <20080328141246.GD29218@elte.hu>
References: <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <20080327.183844.74572930.davem@davemloft.net> <20080328102931.GA23039@gondor.apana.org.au> <20080328105629.GG1011@elte.hu> <20080328110621.GA23342@gondor.apana.org.au> <20080328112928.GA23547@gondor.apana.org.au> <1206706759.4429.58.camel@localhost> <20080328132643.GA24180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@davemloft.net>,
	Matheos.Worku@Sun.COM, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57286 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbYC1ONO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 10:13:14 -0400
Content-Disposition: inline
In-Reply-To: <20080328132643.GA24180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I agree that using jiffies is a pretty coarse approximation of proper 
> scheduling.  However, in the absence of a better solution we have to 
> live with it.
> 
> Perhaps running these out of process context is the correct approach.

yes. Such anonymous work loops inside softirq context are a disaster to 
TCP determinism and a disaster to scheduling in general (the wrong guy 
gets credited with the overhead). Softirqs were a neat hack 10 years 
ago, now if we know the target task for some workload we should execute 
as much of the workload in that task's context as possible. (and even 
for stuff where we dont have a 'target task' - routing, filtering, etc. 
- it might be better to use kernel threads.)

	Ingo
