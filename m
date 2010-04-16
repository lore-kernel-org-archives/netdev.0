From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 10:05:15 -0400
Message-ID: <1271426715.4606.97.camel@bigi>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <87r5mf8va9.fsf@basil.nowhere.org> <1271424726.4606.42.camel@bigi>
	 <20100416134236.GA18855@one.firstfloor.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@halobates.de>, Tom Herbert <therbert@google.com>,
	davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:2877 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab0DPOFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 10:05:18 -0400
Received: by ey-out-2122.google.com with SMTP id d26so219549eyd.19
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 07:05:17 -0700 (PDT)
In-Reply-To: <20100416134236.GA18855@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-16 at 15:42 +0200, Andi Kleen wrote:
> On Fri, Apr 16, 2010 at 09:32:06AM -0400, jamal wrote:
> > How are you going to schedule the net softirq on an empty queue if you
> > do this?
> 
> Sorry don't understand the question? 
> 
> You can always do the flow as if rps was not there.

Meaning you schedule the other side netrx softirq if queue is empty?

> I meant an IPI to a sibling is not useful. You send it to the IPI
> to get cache locality in the target, but if the target has the same
> cache locality as you you can as well avoid the cost of the IPI
> and process directly.
> 

Isnt the purpose of the IPI to signal remote side that theres something
for it to do? Does it also sync the remote cache?

> For thread sibling I'm pretty sure it's useless. Not full sure about
> socket sibling. Maybe.
> 

Agreed, the SMT threads share L2. All the cores share L3. And it is
inclusive, so if it is missing it is in L1 of one thread it must be
present in L2 of shared cache as well as L3. Across the QPI i dont think
that is true.
But if you speacial case this - arent you being specific to Nehalem?

cheers,
jamal

