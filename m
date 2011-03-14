From: Michael Smith <msmith@cbnco.com>
Subject: Re: [PATCH] Disable rp_filter for IPsec packets
Date: Mon, 14 Mar 2011 18:23:20 -0400
Message-ID: <4D7E9558.7030102@cbnco.com>
References: <4D7E88C7.5080706@cbnco.com>	<20110314.144156.245399355.davem@davemloft.net>	<4D7E928C.1030707@cbnco.com> <20110314.151424.212690587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:42647 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529Ab1CNWXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 18:23:22 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id DC7469456E3
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 18:23:21 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 20458-07 for <netdev@vger.kernel.org>;
 Mon, 14 Mar 2011 18:23:21 -0400 (EDT)
Received: from [172.20.22.83] (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPSA id A6DD29423FD
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 18:23:21 -0400 (EDT)
In-Reply-To: <20110314.151424.212690587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> Existing arguments might be large enough to carry more than one piece
> of information :-)

If it's encoded into another argument, would there be more overhead from 
bit-shifting it out than you'd save by losing an argument?

>> I might split the RPF out from the spec_dst calculation, move the
>> whole lot into net/ipv4/route.c, and only do the fib_lookup() if RPF
>> is enabled or CONFIG_IP_ROUTE_CLASSID (i.e. we need to know the itag).
> 
> Can't split two two things up, because spec_dst is a product of the
> reverse FIB lookup, in the form of FIB_RES_PREFSRC().

True, but the result of the reverse FIB lookup could be passed around.

Mike
