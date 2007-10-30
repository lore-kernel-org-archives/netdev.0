From: Brian Haley <brian.haley@hp.com>
Subject: Re: Configuring the same IP on multiple addresses
Date: Tue, 30 Oct 2007 00:23:40 -0400
Message-ID: <4726B1CC.2070203@hp.com>
References: <47262079.90507@hp.com>	<20071029.152559.174870963.davem@davemloft.net> <20071029.154258.39630263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:45873 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbXJ3EYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 00:24:10 -0400
In-Reply-To: <20071029.154258.39630263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 29 Oct 2007 15:25:59 -0700 (PDT)
> 
>> Can you guys please just state upfront what virtualization
>> issue is made more difficult by features you want to remove?
> 
> Sorry, I mentioned "virtualization" because that's been the
> largest majority of the cases being presented lately.
> 
> I suspect in your case it's some multicast or SCTP thing :-)

It's actually neither in this case :)

We have customers migrating from BSD stacks to Linux.  They notice all 
the differences in the sockets API, sometimes even find bugs, and we fix 
them and send patches upstream.  They also do stupid things like 
duplicate address configurations on two interfaces in different subnets.

IPv6 was the curious one for us here since it falls into an RFC gray 
area - addresses are assigned to interfaces, not hosts (RFC 4291), but 
they should be tested for uniqueness before being assigned (RFC 4862). 
This address didn't pass the uniqueness test, although it did pass DAD 
because the links were different.  We couldn't find another OS for a 
host or router (including IOS) that allows this, hence the question.

Thanks, and sorry if it's just another waste of your time to explain it.

-Brian
