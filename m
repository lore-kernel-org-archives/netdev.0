From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 23:49:30 +0930
Message-ID: <5370D872.8080901@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com> <5370CB47.4010400@davidnewall.com> <20140512135141.GA13945@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>,
	Lennert Buytenhek <buytenh@gnu.org>,
	Bart De Schuymer <bdschuym@pandora.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:44228 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaELOTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 10:19:34 -0400
In-Reply-To: <20140512135141.GA13945@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/14 23:21, Florian Westphal wrote:
> Agree, bridge should not alter ip options.

It would be easy to remove the call to ip_options_compile instead of 
recalculating checksum after it, but I suspect there may be good reasons 
why this, too, would be wrong.  The source file is br_netfilter.c, 
suggesting that a change in options is needed in some situations.

In the situation that caught my attention, it obviously does it wrong 
(probably didn't add 0.0.0.0 to the route record, probably just 
incremented the pointer; and seriously damaged the timestamps as well as 
an incremented pointer without actually adding a value.)

I'm in a quandary.

Is it possible that bridge has exceeded it's mandate?  I can't find it 
now, but I saw a comment that it just copies packets unchanged. I think 
it's use now goes further than that would allow.

I welcome words of advice.
