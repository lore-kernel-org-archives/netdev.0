From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Tue, 17 Oct 2006 08:22:11 -0400
Message-ID: <4534CAF3.5000505@psc.edu>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>	<20061016202035.6d55b96e@localhost.localdomain>	<45345999.4000300@psc.edu> <20061016.223513.35356292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:59095 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S1750749AbWJQMWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 08:22:25 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061016.223513.35356292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 17 Oct 2006 00:18:33 -0400
> 
>> Stephen Hemminger wrote:
>>> On Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
>>> John Heffner <jheffner@psc.edu> wrote:
>>>> This patch limits the amount of time you will defer sending a TSO segment
>>>> to less than two clock ticks, or the time between two acks, whichever is
>>>> longer.
>>> Okay, but doing any timing on clock ticks makes the behavior dependent
>>> on the value of HZ which doesn't seem desirable. Should this be based
>>> on RTT or a real-time values?
>> It would be nice to use a high res clock so you don't depend on HZ, but 
>> this is still expensive on most SMP arch's as I understand it.
> 
> Right so we do need to use a jiffies based solution.
> 
> Since HZ is variable, I have a feeling that the thing to do here
> is pick some timeout in msec.  Then replace the "2 clock ticks"
> with some msec_to_jiffies() calls, bottoming out at 1 jiffie.
> 
> How does that sound?

That's actually how I originally coded it. :)  But then it occurred to 
me that if you've already been waiting for a full clock tick, the 
marginal CPU savings of waiting longer will not be great.  Which is why 
I chose the value of 2 ticks so you're guaranteed to have waited at 
least one full tick.

   -John
