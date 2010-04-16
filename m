From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 15:42:36 +0200
Message-ID: <20100416134236.GA18855@one.firstfloor.org>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com> <87r5mf8va9.fsf@basil.nowhere.org> <1271424726.4606.42.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@halobates.de>, Tom Herbert <therbert@google.com>,
	davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39759 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab0DPNmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:42:37 -0400
Content-Disposition: inline
In-Reply-To: <1271424726.4606.42.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 09:32:06AM -0400, jamal wrote:
> How are you going to schedule the net softirq on an empty queue if you
> do this?

Sorry don't understand the question? 

You can always do the flow as if rps was not there.

> BTW, in my tests sending an IPI to an SMT sibling or to another core
> didnt make any difference in terms of latency - still 5 microsecs.
> I dont have dual Nehalem where we have to cross QPI - there i suspect
> it will be longer than 5 microsecs.

I meant an IPI to a sibling is not useful. You send it to the IPI
to get cache locality in the target, but if the target has the same
cache locality as you you can as well avoid the cost of the IPI
and process directly.

For thread sibling I'm pretty sure it's useless. Not full sure about
socket sibling. Maybe.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
