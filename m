From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: possible NAPI improvements to reduce interrupt rates for
 low traffic rates
Date: Mon, 10 Sep 2007 10:25:09 +0100
Message-ID: <46E50D75.1010500@katalix.com>
References: <200709061416.l86EG0Vb017675@quickie.katalix.com> <1189120020.4259.68.camel@localhost> <46E11A61.9030409@katalix.com> <20070907212044.GA9786@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	mandeep.baines@gmail.com, ossthema@de.ibm.com, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Jason Lunz <lunz@gehennom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38348 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079AbXIJJZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 05:25:13 -0400
In-Reply-To: <20070907212044.GA9786@falooley.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> I'd be particularly interested to see what happens to your latency when
> other apps are hogging the cpu. I assume from your description that your
> cpu is mostly free to schedule the niced softirqd for the device polling
> duration, but this won't always be the case. If other tasks are running
> at high priority, it could be nearly a full jiffy before softirqd gets
> to check the poll list again and the latency introduced could be much
> higher than you've yet measured.

Indeed. The effect of cpu load on all of this is important to consider. 
The challenge will be how to test it fairly on different test runs.

One thing to bear in mind is that interrupts are processed at highest 
priority, above any scheduled work. Reducing interrupt rate gives the 
scheduler more chance to run what it thinks is the next highest priority 
work. This might be at the expense of network processing. Is it better 
to give other runnable tasks a fair chunk of the cpu pie? I think so.

I'll try to incorporate application cpu load into my tests. Thanks for 
your feedback.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

