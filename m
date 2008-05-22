From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc" to sch_netem
 module are not interpreted correctly
Date: Thu, 22 May 2008 09:32:14 -0700
Message-ID: <4835A00E.2050908@hp.com>
References: <20080521214523.GB22591@codemonkey.org.uk>	<20080521151021.3d47a3d8@extreme>	<20080522002155.GP20815@postel.suug.ch> <4834C4FE.4060502@hp.com> <20080522111835.GQ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:33667 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753935AbYEVQcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 12:32:18 -0400
In-Reply-To: <20080522111835.GQ20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I looked at netrt_rtnetlink.c, the problem is unrelated. Look at
> the code when adding the source attribtue:
> 
>   struct rtattr *rtap;
> 
>   if (source) {
>     rtap +=  rtap->rta_len;
> 
> You want to increment rtap by rta_len bytes, not rta_len*sizeof(*rtap)
> bytes.
> 
> Also, the code uses RTA_LENGTH() to calculate attributes sizes which
> is wrong, it must use RTA_SPACE() as RTA_LENGTH() does not align the
> actual data part and thus the next attribute is unaligned if the data
> of the previous attribute is not aligned to 4 bytes.

I'll make the fixes in the netperf code - thanks, hope the bugs there 
weren't too big a distraction.

rick jones

