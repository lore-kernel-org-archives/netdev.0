From: Michael Smith <msmith@cbnco.com>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 18:11:24 -0400
Message-ID: <4D7E928C.1030707@cbnco.com>
References: <1300137299-28161-1-git-send-email-msmith@cbnco.com>	<20110314.142520.28811818.davem@davemloft.net>	<4D7E88C7.5080706@cbnco.com> <20110314.144156.245399355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:47098 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab1CNWL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 18:11:26 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id 3CE5DA97E5A
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 18:11:26 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 18832-10 for <netdev@vger.kernel.org>;
 Mon, 14 Mar 2011 18:11:26 -0400 (EDT)
Received: from [172.20.22.83] (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPSA id 05417A97D66
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 18:11:25 -0400 (EDT)
In-Reply-To: <20110314.144156.245399355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> What would be a less costly way to pass it? Could I just hand it the
>> whole skb?
> 
> I don't see how passing a pointer is better than passing an interger.
> In both cases you're adding an extra argument to the function.

Yeah, I was thinking an sk_buff could replace the mark parameter, 
possibly dev, maybe saddr, daddr, and tos too. On the other hand I can't 
think of anything less onerous than an extra stack argument - unless 
fib_validate_source() didn't exist at all.

> I was trying to get you to think out of the box and come up with
> something clever, but that isn't working. :-)

Yes, I got that, but I don't know what you are looking for, and don't 
expect to succeed by trying something else at random.

> In short, fib_validate_source() is nothing but completely unnecessary
> overhead in the common case.

I'm not entitled to an opinion about fib_validate_source(). It feels 
like it might be trying to do one too many things. If it were my code I 
might split the RPF out from the spec_dst calculation, move the whole 
lot into net/ipv4/route.c, and only do the fib_lookup() if RPF is 
enabled or CONFIG_IP_ROUTE_CLASSID (i.e. we need to know the itag).

If that makes sense I'll give it a shot, but beware, I don't even know 
what an itag is, and I don't see documentation for CONFIG_IP_ROUTE_CLASSID.

Thanks,
Mike
