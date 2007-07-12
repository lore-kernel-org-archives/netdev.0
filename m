From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Thu, 12 Jul 2007 15:27:30 -0700
Message-ID: <4696AAD2.9030405@hp.com>
References: <20070712.161510.26510093.noboru.obata.ar@hitachi.com>	<20070712.023710.36923635.davem@davemloft.net>	<20070712.225950.12335719.noboru.obata.ar@hitachi.com>	<20070712.132448.115910193.davem@davemloft.net>	<20070712141203.7350429a@freepuppy.rosehill.hemminger.net>	<46969CA9.8030406@hp.com> <20070712150229.7a841c4d@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: noboru.obata.ar@hitachi.com, David Miller <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:35058 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755567AbXGLW2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 18:28:13 -0400
In-Reply-To: <20070712150229.7a841c4d@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So the problem is that RTO can grows to be twice the failover detection
> time.  So back to the original mail, the scenario has a switch with failover
> detection of 20seconds.  Worst case TCP RTO could grow to 40 seconds.
> 
> Going back in archive to original mail:
> 
> 
>>Background
>>==========
>>
>>When designing a TCP/IP based network system on failover-capable
>>network devices, people want to set timeouts hierarchically in
>>three layers, network device layer, TCP layer, and application
>>layer (bottom-up order), such that:
>>
>>1. Network device layer detects a failure first and switch to a
>>   backup device (say, in 20sec).
>>
>>2. TCP layer timeout & retransmission comes next, _hopefully_
>>   before the application layer timeout.
>>
>>3. Application layer detects a network failure last (by, say,
>>   30sec timeout) and may trigger a system-level failover.
> 
> 
> Sounds like the solution is to make the switch failover detection faster.
> If you get switch failover down to 5sec then TCP RTO shouldn't be bigger
> than 10sec, and application will survive.

That may indeed be the best solution, we'll have to wait to hear if 
there is any freedom there.  When this sort of thing has crossed my path 
in other contexts, the general answer is that the device failover time 
is fixed, and the application layer time is similarly constrained by 
end-user expectation/requirement.  Often as not, layer 8 and 9 issues 
tend to dominate and expect to trump (in this case layer 4 issues).

rick jones
