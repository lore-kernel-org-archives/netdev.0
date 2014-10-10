From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt context.
Date: Thu, 9 Oct 2014 21:56:45 -0700
Message-ID: <960E9AF5-0319-44C7-9A1C-37EAEE52E78E@oracle.com>
References: <20141006.152526.965519223260573233.davem@davemloft.net> <20141006193111.GE24721@oracle.com> <EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com> <20141010.003628.646817757614430018.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27492 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbaJJE4u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:56:50 -0400
In-Reply-To: <20141010.003628.646817757614430018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 9, 2014, at 9:36 PM, David Miller <davem@davemloft.net> wrote:

> From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
> Date: Thu, 9 Oct 2014 18:10:24 -0700
> 
>> Lock less Tx and Rx implementation is very nice, but requires to the
>> code path to single threaded to achieve it.
> 
> I would like to know how you believe the Linux LLTX "lockless TX"
> facility works.
> 

Sorry, I used incorrect terminology in my email. My knowledge of LLTX
is limited and I am still learning. I was not referring to the LLTX, but  about 
the implementation of  sunvnet transmit path and receive paths without locks. To me that
means only one thread of execution exists at a given time and I was
referring to it as single threadedness,  which limits performance on SPARC CMT
processors today. Using  methods to increase parallelism will help especially
when the traffic involves multiple connections, mainly from the point of view
of using multiple vCPUs to perform the processing where possible. 

-Raghuram

> It's not truly lockless, it just turns off the generic networking TX
> path per-queue spinlock and puts the full burdon on the driver.  It's
> just moving the locking from one place to another, not eliminating it.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
