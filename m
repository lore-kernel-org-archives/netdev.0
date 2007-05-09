From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Wed, 09 May 2007 08:56:43 -0400
Message-ID: <1178715404.4073.21.camel@localhost>
References: <20070508.233630.35664266.davem@davemloft.net>
	 <OF6A57F86D.C63329E8-ON652572D6.0027B2E9-652572D6.00289106@in.ibm.com>
	 <20070509.011201.68040843.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:50470 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbXEIM4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 08:56:47 -0400
Received: by wx-out-0506.google.com with SMTP id h31so169914wxd
        for <netdev@vger.kernel.org>; Wed, 09 May 2007 05:56:47 -0700 (PDT)
In-Reply-To: <20070509.011201.68040843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-05 at 01:12 -0700, David Miller wrote:

> Something this evening is obviously making it impossible
> for my brain to understand this function and your patch,
> so I'm going to sleep on it and try again tomorrow :-)

It is one of those areas that are hard to size-up in a blink;->
Gut-feeling: It doesnt sit right with me as well.
 
With (2.6.18-rxX++) QDISC_RUNNING changes that mean only one of N CPUs
will be dequeueing while the N-1 maybe enqueueing concurently. All N
CPUs contend for the queue lock; and theres a possible window between
releasing the queue lock by the dequeuer-CPU and enqueuer-CPU for a
race. The dequeuer-CPU entering one last time helps.

Krishna, you probably saw this "wasted entry into qdisc" under low
traffic conditions with more than likely only one CPU sending, am i
correct? Under heavier traffic when we have multiple CPUs funneling to
the same device, that entry is not really a "waste" because we endup
only go in once per X number of packets enqueued on the qdisc and that
check is absolutely necessary because a different CPU may have enqueued
while you were not looking. In the case of low traffic, X=1 - so it is a
waste there albeit a necessary one.

cheers,
jamal


