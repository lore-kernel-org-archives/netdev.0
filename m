From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 21:30:26 +0100
Message-ID: <20061130203026.GD14696@elte.hu>
References: <456EAD6E.6040709@yahoo.com.au> <20061130102205.GA20654@2ka.mipt.ru> <20061130103240.GA25733@elte.hu> <20061130.122258.68041055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, nickpiggin@yahoo.com.au, wenji@fnal.gov,
	akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47007 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1031402AbWK3UbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 15:31:03 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061130.122258.68041055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> I want to point out something which is slightly misleading about this 
> kind of analysis.
> 
> Your disk I/O speed doesn't go down by a factor of 10 just because 9 
> other non disk I/O tasks are running, yet for TCP that's seemingly OK
> :-)

disk I/O is typically not CPU bound, and i believe these TCP tests /are/ 
CPU-bound. Otherwise there would be no expiry of the timeslice to begin 
with and the TCP receiver task would always be boosted to 'interactive' 
status by the scheduler and would happily chug along at 500 mbits ...

(and i grant you, if a disk IO test is 20% CPU bound in process context 
and system load is 10, then the scheduler will throttle that task quite 
effectively.)

	Ingo
