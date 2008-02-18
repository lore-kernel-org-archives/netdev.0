From: Martin Devera <devik@cdi.cz>
Subject: Re: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Mon, 18 Feb 2008 11:08:09 +0100
Message-ID: <47B95909.8060202@cdi.cz>
References: <E1JPn6W-0002J2-5x@luxik.cdi.cz>	<20080217.232829.222344360.davem@davemloft.net>	<47B93BE8.7010905@cdi.cz> <20080218.001736.124204016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:49775 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756906AbYBRKIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 05:08:12 -0500
In-Reply-To: <20080218.001736.124204016.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Martin Devera <devik@cdi.cz>
> Date: Mon, 18 Feb 2008 09:03:52 +0100
> 
>> aha, ok, I'm not so informed about crossplatform issues.
>> I was also thining about looking at jiffies value and stop once
>> it is startjiffy+2, but with NO_HZ introduction, are jiffies
>> still incremented ?
> 
> There should always be at least once cpu tasked with incrementing
> jiffies.  Lots of stuff would break if not :-)
> 

Aha ok, so that when (at least one) cpu is busy then I can count on
jiffies incrementing via do_timer, can't I ?
So that I'd remove the loop limit altogether but limiting it to
1 or 2 jiffies to prevent livelock.
Like
max_jiff = jiffies+2; /* not +1 at we could be at +0.9999 now */
while (jiffies<max_jiff) do_hard_potentionaly_long_work();
if (more_work) schedule_to_next_jiffie();

This will keep event queue work load under 66% of system load which
seems reasonable to me.

Would you accept such solution ?
